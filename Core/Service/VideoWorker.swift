import AVKit
import Foundation
import OSLog
import SwiftUI
import MagicKit

class VideoWorker: NSObject, ObservableObject, SuperPlayWorker, SuperLog {
    // MARK: 成员

    static var emoji = "💿"
    var player = AVPlayer()
    var asset: PlayAsset?
    var verbose = false
    var queue = DispatchQueue(label: "VideoWorker", qos: .userInteractive)

    // MARK: 状态改变时

    var state: PlayState = .Stopped {
        didSet {
            if verbose {
                os_log("\(self.t)State changed 「\(oldValue.des)」 -> 「\(self.state.des)」")
            }

            var e: Error?

            asset = state.getAsset()

            switch state {
            case .Ready:
                do {
                    try player = makePlayer(asset)
                } catch {
                    e = error
                }
            case let .Playing(audio):
                if let oldAudio = oldValue.getPausedAudio(), oldAudio.url == audio.url {
                    player.play()
                } else {
                    do {
                        asset = audio
                        player.pause()
                        try player = makePlayer(audio)
                        player.play()
                    } catch {
                        e = error
                    }
                }
            case .Paused:
                player.pause()
            case .Stopped:
                player.pause()
            case .Finished:
                player.pause()
            case .Error:
                player = makeEmptyPlayer()
            }

            onStateChange(state)

            if let ee = e {
                setError(ee, asset: asset)
            }
        }
    }

    @Published var duration: TimeInterval = 0

    func updateDuration() {
        if #available(macOS 13.0, iOS 16.0, *) {
            Task {
                do {
                    let durationSeconds = try await player.currentItem?.asset.load(.duration).seconds ?? 0
                    DispatchQueue.main.async {
                        self.duration = durationSeconds
                    }
                } catch {
                    os_log("\(self.t)Error loading duration: \(error.localizedDescription)")
                    // Optionally, you can set a default duration or handle the error in another way
                    DispatchQueue.main.async {
                        self.duration = 0
                    }
                }
            }
        } else {
            duration = player.currentItem?.asset.duration.seconds ?? 0
        }
    }

    var currentTime: TimeInterval { 0 }
    var leftTime: TimeInterval { duration - currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }

    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    // MARK: 对外传递事件

    var onStateChange: (_ state: PlayState) -> Void = { state in
        os_log("\(t)播放器状态已变为 \(state.des)")
    }
    
    var onGetPrevOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(t)GetPrevOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onGetNextOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(t)GetNextOf -> \(asset?.title ?? "nil")")
        return nil
    }
}

// MARK: 播放控制

extension VideoWorker {
    func setError(_ e: Error, asset: PlayAsset?) {
        state = .Error(e, asset)
    }

    func goto(_ time: TimeInterval) {
//        player.currentTime = time
    }

    func prepare(_ audio: PlayAsset, reason: String, verbose: Bool) {
        state = .Ready(audio)
    }

    func play(_ audio: PlayAsset, reason: String, verbose: Bool) {
        os_log("\(self.t)play \(audio.title) 🐛 \(reason)")
        state = .Playing(audio)
        updateDuration()
    }

    func resume() {
        os_log("\(self.t)Resume while current is \(self.state.des)")
        switch state {
        case .Playing, .Error:
            break
        case .Ready, .Paused, .Stopped, .Finished:
            state = .Playing(asset!)
        }
    }

    func pause(verbose: Bool) {
        os_log("\(self.t)Pause")
        state = .Paused(asset)
    }

    func stop(reason: String, verbose: Bool) {
        if verbose {
            os_log("\(self.t)Stop 🐛 \(reason)")
        }
        state = .Stopped
    }

    func toggle() {
        state.isPlaying ? pause(verbose: true) : resume()
    }
    
    // MARK: Prev
    
    func prev() {
//        if let prev = self.onGetPrevOf(self.asset) {
//            self.play(prev, reason: "Prev")
//        } else {
//            self.stop(reason: "prev")
//        }
    }
}

// MARK: 控制 AVAudioPlayer

extension VideoWorker {
    func makeEmptyPlayer() -> AVPlayer {
        AVPlayer()
    }

    func makePlayer(_ asset: PlayAsset?) throws -> AVPlayer {
        guard let audio = asset else {
            return AVPlayer()
        }

        if audio.isNotExists() {
            throw SmartError.NotExists
        }

        if audio.isDownloading {
            os_log("\(self.t)在下载 \(audio.title) ⚠️⚠️⚠️")
            throw SmartError.Downloading
        }

        // 未下载的情况
        guard audio.isDownloaded else {
            os_log("\(self.t)未下载 \(audio.title) ⚠️⚠️⚠️")
            throw SmartError.NotDownloaded
        }

        // 格式不支持
//        guard audio.isSupported else {
//            os_log("\(self.t)格式不支持 \(audio.title) \(audio.ext)")
//            throw SmartError.FormatNotSupported(audio.ext)
//        }

        #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        #endif
        player = AVPlayer(url: audio.url)

        return player
    }
}
