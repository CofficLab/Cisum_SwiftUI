import AVKit
import Foundation
import MagicKit
import MediaPlayer
import OSLog
import SwiftUI

/* 负责
      接收用户播放控制事件
      接收系统播放控制事件
      对接系统媒体中心
 */

class AudioWorker: NSObject, ObservableObject, PlayWorker, SuperLog, SuperThread {
    // MARK: 成员

    static var label = "💿 AudioWorker::"
    let emoji = "🎺"
    var player = AVAudioPlayer()
    var asset: PlayAsset?
    var verbose = false
    var queue = DispatchQueue(label: "AudioWorker", qos: .userInteractive)

    // MARK: 状态改变时

    var state: PlayState = .Stopped {
        didSet {
            if verbose {
                os_log("\(self.t)State changed 「\(oldValue.des)」 -> 「\(self.state.des)」")
            }

            var e: Error?

            self.asset = self.state.getAsset()

            switch state {
            case .Ready:
                do {
                    try player = makePlayer(self.asset, reason: "AudioWorker.Ready")
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
                        try player = makePlayer(asset, reason: "AudioWorker.Playing")
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

    var onGetNextOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(AudioWorker.label)GetNextOf -> \(asset?.title ?? "nil")")
        return nil
    }

    var onToggleMode: () -> Void = {
        os_log("\(AudioWorker.label)ToggleMode")
    }
}

// MARK: 播放控制

extension AudioWorker {
    func goto(_ time: TimeInterval) {
        player.currentTime = time
    }

    func prepare(_ asset: PlayAsset?, reason: String) {
        let verbose = false
        if verbose {
            os_log("\(self.t)Prepare \(asset?.fileName ?? "nil") \(reason)")
        }
        self.state = .Ready(asset)
    }

    // MARK: Play

    func play(_ asset: PlayAsset, reason: String) {
        let verbose = false
        if verbose {
            os_log("\(self.t)Play \(asset.fileName) 🐛 \(reason)")
        }

        if asset.isFolder() {
            return prepare(asset, reason: reason)
        }

        self.state = .Playing(asset)
    }

    func play() {
        os_log("\(self.t)Play")
        DispatchQueue.main.async {
            self.resume()
        }
    }

    func resume() {
        let verbose = false
        if verbose {
            os_log("\(self.t)Resume")
        }

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
        let verbose = false
        if verbose {
            os_log("\(self.t)Pause")
        }
        state = .Paused(asset)
    }

    func stop() {
        os_log("\(self.t)Stop")
        state = .Stopped
    }

    func finish() {
        let verbose = false
        if verbose {
            os_log("\(self.t)Finish(\(self.asset?.title ?? "nil"))")
        }
        guard let asset = self.asset else {
            return
        }

        state = .Finished(asset)
    }

    func toggle() {
        isPlaying ? pause() : resume()
    }
}

// MARK: 控制 AVAudioPlayer

extension AudioWorker {
    func makeEmptyPlayer() -> AVAudioPlayer {
        AVAudioPlayer()
    }

    func makePlayer(_ asset: PlayAsset?, reason: String) throws -> AVAudioPlayer {
        let verbose = false
        if verbose {
            os_log("\(self.t)MakePlayer「\(asset?.fileName ?? "nil")」 🐛 \(reason)")
        }

        guard let asset = asset else {
            return AVAudioPlayer()
        }

        if asset.isNotExists() {
            os_log("\(self.t)不存在 \(asset.fileName) ⚠️⚠️⚠️")
            throw PlayManError.NotFound
        }

        if asset.isDownloading {
            if verbose {
                os_log("\(self.t)正在下载 \(asset.fileName)")
            }
            throw PlayManError.Downloading
        }

        guard asset.isDownloaded else {
            if verbose {
                os_log("  ⚠️ 未下载 \(asset.fileName)")
            }
            throw PlayManError.NotDownloaded
        }

        // 格式不支持
        guard asset.isSupported() else {
            os_log("\(self.t)格式不支持 \(asset.fileName) \(asset.ext)")
            throw PlayManError.FormatNotSupported(asset.ext)
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            player = try AVAudioPlayer(contentsOf: asset.url)
        } catch {
            os_log(.error, "\(self.t)初始化播放器失败 ->\(asset.fileName)->\(error)")
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
        let verbose = false

        self.bg.async {
            // 没有播放完，被打断了
            if !flag {
                os_log("\(self.t)播放被打断，更新为暂停状态")
                return self.pause()
            }

            if verbose {
                os_log("\(self.t)播放完成")
            }
            self.finish()
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        os_log("\(self.t)audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        os_log("\(self.t)audioPlayerBeginInterruption")
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        os_log("\(self.t)audioPlayerEndInterruption")
        resume()
    }
}
