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

protocol AudioWorkerDelegate: AnyObject {
    func onPlayFinished(verbose: Bool)
}

class AudioWorker: NSObject, ObservableObject, SuperPlayWorker, SuperLog, SuperThread {
    let emoji = "🎺"
    var player = AVAudioPlayer()
    var asset: PlayAsset?
    var delegate: AudioWorkerDelegate?
    var verbose = false
    var queue = DispatchQueue(label: "AudioWorker", qos: .userInteractive)
    var state: PlayState = .Stopped
    var duration: TimeInterval { player.duration }
    var currentTime: TimeInterval { player.currentTime }
    var leftTime: TimeInterval { duration - currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }

    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    init(delegate: AudioWorkerDelegate?) {
        self.delegate = delegate
    }

    func goto(_ time: TimeInterval) {
        player.currentTime = time
    }

    func prepare(_ asset: PlayAsset?, reason: String, verbose: Bool) throws {
        self.asset = asset
        self.player = try self.makePlayer(asset, reason: reason, verbose: verbose)
    }

    func play(_ asset: PlayAsset, reason: String) throws {
        let verbose = false
        if verbose {
            os_log("\(self.t)Play \(asset.fileName) 🐛 \(reason)")
        }

        if asset.isFolder() {
            return try prepare(asset, reason: reason, verbose: true)
        }

        try player = makePlayer(asset, reason: "AudioWorker.Playing", verbose: true)
        self.asset = asset
        self.player.prepareToPlay()
        self.player.play()
    }

    func play() throws {
        self.player.play()
    }

    func pause(verbose: Bool) {
        let verbose = false
        if verbose {
            os_log("\(self.t)Pause")
        }
        self.player.pause()
    }

    func stop(reason: String, verbose: Bool) {
        self.player.stop()
        self.goto(0)
    }

    func toggle() throws {
        isPlaying ? pause(verbose: true) : try play()
    }
}

// MARK: 控制 AVAudioPlayer

extension AudioWorker {
    func makeEmptyPlayer() -> AVAudioPlayer {
        AVAudioPlayer()
    }

    func makePlayer(_ asset: PlayAsset?, reason: String, verbose: Bool) throws -> AVAudioPlayer {
        guard let asset = asset else {
            return AVAudioPlayer()
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
        let verbose = true

        if !flag {
            os_log("\(self.t)播放被打断，更新为暂停状态")
            return self.pause(verbose: true)
        }

        self.delegate?.onPlayFinished(verbose: verbose)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        os_log("\(self.t)audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        os_log("\(self.t)audioPlayerBeginInterruption")
        pause(verbose: true)
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        os_log("\(self.t)audioPlayerEndInterruption")
        try? play()
    }
}
