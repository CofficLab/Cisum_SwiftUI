import AVKit
import MediaPlayer
import Foundation
import OSLog
import SwiftUI

/* 负责
      接收用户播放控制事件
      接收系统播放控制事件
      对接系统媒体中心
 */

class AudioWorker: NSObject, ObservableObject, PlayWorker {
    // MARK: 成员

    static var label = "💿 AudioWorker::"
    var label: String { Logger.isMain + Self.label }
    var player = AVAudioPlayer()
    var asset: PlayAsset?
    @Published var mode: PlayMode = .Order
    var verbose = false
    var queue = DispatchQueue(label: "AudioWorker", qos: .userInteractive)

    // MARK: 状态改变时

    @Published var state: PlayState = .Stopped {
        didSet {
            if verbose {
                os_log("\(Logger.isMain)\(self.label)State changed 「\(oldValue.des)」 -> 「\(self.state.des)」")
            }
            
            var e: Error? = nil
            
            self.asset = self.state.getAsset()

            switch state {
            case .Ready(_):
                do {
                    try player = makePlayer(self.asset)
                    player.prepareToPlay()
                } catch {
                    e = error
                }
            case let .Playing(asset):
                if let oldAudio = oldValue.getPausedAudio(), oldAudio.url == asset.url {
                    player.play()
                } else {
                    do {
                        self.asset = asset
                        try player = makePlayer(asset)
                        player.prepareToPlay()
                        player.play()
                    } catch {
                        e = error
                    }
                }
            case .Paused:
                player.pause()
            case .Stopped:
                player.stop()
                player = makeEmptyPlayer()
            case .Finished:
                player.stop()
            case .Error:
                player = makeEmptyPlayer()
            }
            
            self.onStateChange(state)
            
            if let ee = e {
                setError(ee, asset: self.asset)
            }
        }
    }

    var duration: TimeInterval { player.duration }
    var currentTime: TimeInterval { player.currentTime }
    var leftTime: TimeInterval { duration - currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }

    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    // MARK: 对外传递事件

    var onStateChange: (_ state: PlayState) -> Void = { state in
        os_log("\(AudioWorker.label)播放器状态已变为 \(state.des)")
    }
    
    var onGetPrevOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(AudioWorker.label)GetPrevOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onGetNextOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(AudioWorker.label)GetNextOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onToggleMode: () -> Void = {
        os_log("\(AudioWorker.label)ToggleMode")
    }
}

// MARK: 播放模式

extension AudioWorker {
    func switchMode(verbose: Bool = true) {
        mode = mode.switchMode()
        Config.setCurrentMode(mode)
        onToggleMode()
    }
}

// MARK: 播放控制

extension AudioWorker {
    func goto(_ time: TimeInterval) {
        player.currentTime = time
    }

    func prepare(_ asset: PlayAsset?) {
        os_log("\(self.label)Prepare \(asset?.fileName ?? "nil")")
        DispatchQueue.main.async {
            self.state = .Ready(asset)
        }
        
    }

    // MARK: Play
    
    func play(_ asset: PlayAsset, reason: String) {
        os_log("\(self.label)Play \(asset.fileName) 🐛 \(reason)")
        
        if asset.isFolder() {
            return prepare(asset)
        }
        
        DispatchQueue.main.async {
            self.state = .Playing(asset)
        }
    }

    func play() {
        os_log("\(self.label)Play")
        DispatchQueue.main.async {
            self.resume()
        }
    }

    func resume() {
        os_log("\(self.label)Resume while current is \(self.state.des)")
        switch state {
        case .Playing:
            break
        case .Error, .Ready, .Paused, .Stopped, .Finished:
            if let asset = asset {
                state = .Playing(asset)
            } else {
                state = .Error(SmartError.NoAudioInList, nil)
            }
        }
    }

    func pause() {
        os_log("\(self.label)Pause")
        state = .Paused(asset)
    }

    func stop() {
        os_log("\(self.label)Stop")
        state = .Stopped
    }
    
    func finish() {
        os_log("\(self.label)Finish(\(self.asset?.title ?? "nil"))")
        guard let asset = self.asset else {
            return
        }
        
        state = .Finished(asset)
    }

    func toggle() {
        isPlaying ? pause() : resume()
    }
    
    // MARK: Prev
    
    func prev() {
        if let prev = self.onGetPrevOf(self.asset) {
            self.play(prev, reason: "Prev")
        } else {
            self.stop()
        }
    }
}

// MARK: 控制 AVAudioPlayer

extension AudioWorker {
    func makeEmptyPlayer() -> AVAudioPlayer {
        AVAudioPlayer()
    }

    func makePlayer(_ asset: PlayAsset?) throws -> AVAudioPlayer {
        guard let asset = asset else {
            return AVAudioPlayer()
        }

        if asset.isNotExists() {
            os_log("\(self.label)不存在 \(asset.fileName) ⚠️⚠️⚠️")
            throw SmartError.NotExists
        }

        if asset.isDownloading {
            os_log("\(self.label)在下载 \(asset.fileName) ⚠️⚠️⚠️")
            throw SmartError.Downloading
        }

        // 未下载的情况
        guard asset.isDownloaded else {
            os_log("\(self.label)未下载 \(asset.fileName) ⚠️⚠️⚠️")
            throw SmartError.NotDownloaded
        }

        // 格式不支持
        guard asset.isSupported() else {
            os_log("\(self.label)格式不支持 \(asset.fileName) \(asset.ext)")
            throw SmartError.FormatNotSupported(asset.ext)
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            player = try AVAudioPlayer(contentsOf: asset.url)
        } catch {
            os_log(.error, "\(self.label)初始化播放器失败 ->\(asset.fileName)->\(error)")
            player = AVAudioPlayer()
        }

        player.delegate = self

        return player
    }
}

// MARK: 播放状态

extension AudioWorker {
    func setError(_ e: Error, asset: PlayAsset?) {
        state = .Error(e, asset)
    }

    var isReady: Bool {
        if case .Ready = state {
            return true
        } else {
            return false
        }
    }

    var isPlaying: Bool {
        if case .Playing = state {
            return true
        } else {
            return false
        }
    }
    
    var isNotPlaying: Bool {
        !isPlaying
    }
}

// MARK: 接收系统事件

extension AudioWorker: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        queue.sync {
            // 没有播放完，被打断了
            if !flag {
                os_log("\(Logger.isMain)\(self.label)播放被打断，更新为暂停状态")
                return pause()
            }

            if self.mode == .Loop {
                os_log("\(self.label)播放完成，单曲循环")
                if let asset = self.asset {
                    self.play(asset, reason: "单曲循环")
                } else {
                    self.finish()
                }
            } else {
                os_log("\(self.label)播放完成，\(self.mode.description)")
                self.finish()
            }
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        os_log("\(Logger.isMain)\(self.label)audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        os_log("\(Logger.isMain)\(self.label)audioPlayerBeginInterruption")
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        os_log("\(Logger.isMain)\(self.label)audioPlayerEndInterruption")
        resume()
    }
}
