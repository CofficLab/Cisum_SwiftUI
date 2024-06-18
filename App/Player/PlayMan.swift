import AVKit
import Foundation
import OSLog
import SwiftUI

class PlayMan: NSObject {
    // MARK: 成员

    static var label = "💿 SmartPlayer::"
    var label: String { Logger.isMain + Self.label }
    var player = AVAudioPlayer()
    var asset: PlayAsset?
    var verbose = false
    var queue = DispatchQueue(label: "SmartPlayer", qos: .userInteractive)

    // MARK: 状态改变时

    var state: PlayState = .Stopped {
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
                player.currentTime = 0
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
        os_log("\(PlayMan.label)播放器状态已变为 \(state.des)")
    }
}

// MARK: 播放控制

extension PlayMan {
    func goto(_ time: TimeInterval) {
        player.currentTime = time
    }

    func prepare(_ audio: Audio?) {
        state = .Ready(asset)
    }

    func play(_ asset: PlayAsset, reason: String) {
        os_log("\(self.label)play \(asset.title) 🐛 \(reason)")
        state = .Playing(asset)
    }

    func play() {
        os_log("\(self.label)Play")
        resume()
    }

    func resume() {
        os_log("\(self.label)Resume while current is \(self.state.des)")
        switch state {
        case .Playing, .Error:
            break
        case .Ready, .Paused, .Stopped, .Finished:
            state = .Playing(asset!)
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

    func toggle() {
        isPlaying ? pause() : resume()
    }
}

// MARK: 控制 AVAudioPlayer

extension PlayMan {
    func makeEmptyPlayer() -> AVAudioPlayer {
        AVAudioPlayer()
    }

    func makePlayer(_ asset: PlayAsset?) throws -> AVAudioPlayer {
        guard let asset = asset else {
            return AVAudioPlayer()
        }

        if asset.isNotExists() {
            throw SmartError.NotExists
        }

        if asset.isDownloading() {
            os_log("\(self.label)在下载 \(asset.title) ⚠️⚠️⚠️")
            throw SmartError.Downloading
        }

        // 未下载的情况
        guard asset.isDownloaded() else {
            os_log("\(self.label)未下载 \(asset.title) ⚠️⚠️⚠️")
            throw SmartError.NotDownloaded
        }

        // 格式不支持
        guard asset.isSupported() else {
            os_log("\(self.label)格式不支持 \(asset.title) \(asset.ext)")
            throw SmartError.FormatNotSupported(asset.ext)
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            player = try AVAudioPlayer(contentsOf: asset.url)
        } catch {
            os_log(.error, "\(self.label)初始化播放器失败 ->\(asset.title)->\(error)")
            player = AVAudioPlayer()
        }

        player.delegate = self

        return player
    }
}

// MARK: 播放状态

extension PlayMan {
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

extension PlayMan: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        queue.sync {
            // 没有播放完，被打断了
            if !flag {
                os_log("\(Logger.isMain)\(self.label)播放被打断，更新为暂停状态")
                return pause()
            }

            os_log("\(Logger.isMain)\(self.label)播放完成")
            state = .Finished
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
