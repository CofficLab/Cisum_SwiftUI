import AVKit
import Foundation
import MagicKit
import MagicUI
import MediaPlayer
import OSLog
import SwiftUI

/* 负责
      接收用户播放控制事件
      接收系统播放控制事件
      对接系统媒体中心
 */

protocol AudioWorkerDelegate: AnyObject {
    func onPlayFinished(verbose: Bool) async
}

class AudioWorker: NSObject, ObservableObject, SuperPlayWorker, SuperLog, SuperThread {
    static let emoji = "👷"
    var player: AVAudioPlayer?
    var delegate: AudioWorkerDelegate?
    var verbose = false
    var queue = DispatchQueue(label: "AudioWorker", qos: .userInteractive)
    var state: PlayState = .Stopped
    var url: URL? { self.player?.url }
    var duration: TimeInterval { player?.duration ?? 0 }
    var currentTime: TimeInterval { player?.currentTime ?? 0 }
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

    func seek(_ time: TimeInterval) {
        player?.currentTime = time
    }

    private func prepare(_ asset: PlayAsset, reason: String) throws -> AVAudioPlayer {
        let player = try makePlayer(asset, reason: reason, verbose: true)
        player.prepareToPlay()
        
        self.player = player
        
        return player
    }
    
    func prepare(_ asset: PlayAsset, reason: String, verbose: Bool) throws {
        if verbose {
            os_log("\(self.t)Prepare \(asset.fileName) 🐛 \(reason)")
        }
        
        self.player = try prepare(asset, reason: reason)
        self.player!.delegate = self
    }

    func play(_ asset: PlayAsset, reason: String, verbose: Bool) throws {
        if verbose {
            os_log("\(self.t)Play \(asset.fileName) 🐛 \(reason)")
        }

        try self.prepare(asset, reason: reason, verbose: true)
        try self.resume()
    }

    func pause(verbose: Bool) {
        if verbose {
            os_log("\(self.t)Pause")
        }
        
        self.player?.pause()
    }
    
    func resume(_ asset: PlayAsset? = nil) throws {
        let verbose = true
        if verbose {
            os_log("\(self.t)Resume")
        }
        
        if let asset = asset, asset.url != self.url {
            try self.prepare(asset, reason: self.className + ".resume", verbose: false)
        }
        
        self.player?.play()
    }

    func stop(reason: String, verbose: Bool) {
        self.player?.stop()
        self.seek(0)
    }

    func toggle() throws {
        isPlaying ? pause(verbose: true) : try self.resume()
    }
}

// MARK: 控制 AVAudioPlayer

extension AudioWorker {
    func makePlayer(_ asset: PlayAsset, reason: String, verbose: Bool) throws -> AVAudioPlayer {
        if asset.isNotDownloaded {
            os_log(.error, "\(self.t)未下载，等待下载 -> \(asset.title)")
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
            return try AVAudioPlayer(contentsOf: asset.url)
        } catch {
            os_log(.error, "\(self.t)初始化播放器失败 ->\(asset.fileName)->\(error)")
            throw error
        }
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

        Task {
            await self.delegate?.onPlayFinished(verbose: verbose)
        }
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
        try? self.resume()
    }
}

enum AudioWorkerError: Error, LocalizedError {
    case NoAsset
    case NoPlayer

    var description: String {
        switch self {
        case .NoAsset: return "No asset"
        case .NoPlayer: return "No player"
        }
    }
}
