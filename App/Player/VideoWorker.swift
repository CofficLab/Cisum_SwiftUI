import AVKit
import Foundation
import OSLog
import SwiftUI

class VideoWorker: NSObject, ObservableObject, PlayWorker {
    // MARK: 成员

    static var label = "💿 VideoWorker::"
    var label: String { Logger.isMain + VideoWorker.label }
    var player = AVPlayer()
    var asset: PlayAsset?
    var verbose = false
    var queue = DispatchQueue(label: "VideoWorker", qos: .userInteractive)

    // MARK: 状态改变时

    var state: PlayState = .Stopped {
        didSet {
            if verbose {
                os_log("\(Logger.isMain)\(self.label)State changed 「\(oldValue.des)」 -> 「\(self.state.des)」")
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

    var duration: TimeInterval {
        if let duration = player.currentItem?.asset.duration.seconds {
            return duration
        } else {
            return 0
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
        os_log("\(VideoWorker.label)播放器状态已变为 \(state.des)")
    }
    
    var onGetPrevOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(VideoWorker.label)GetPrevOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onGetNextOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(VideoWorker.label)GetNextOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onToggleLike: () -> Void = {
        os_log("\(VideoWorker.label)ToggleLike")
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

    func prepare(_ audio: PlayAsset?) {
        state = .Ready(audio)
    }

    func play(_ audio: PlayAsset, reason: String) {
        os_log("\(self.label)play \(audio.title) 🐛 \(reason)")
        state = .Playing(audio)
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
        state.isPlaying ? pause() : resume()
    }
    
    func toggleLike() {
        self.asset?.like.toggle()
        self.onToggleLike()
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
            os_log("\(self.label)在下载 \(audio.title) ⚠️⚠️⚠️")
            throw SmartError.Downloading
        }

        // 未下载的情况
        guard audio.isDownloaded else {
            os_log("\(self.label)未下载 \(audio.title) ⚠️⚠️⚠️")
            throw SmartError.NotDownloaded
        }

        // 格式不支持
//        guard audio.isSupported else {
//            os_log("\(self.label)格式不支持 \(audio.title) \(audio.ext)")
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
