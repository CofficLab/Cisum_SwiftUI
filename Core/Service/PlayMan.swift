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

class PlayMan: NSObject, ObservableObject, SuperLog, SuperThread, AudioWorkerDelegate {
    // MARK: 成员

    static var label = "💃 PlayMan::"
    #if os(macOS)
        static var defaultImage = NSImage(named: "DefaultAlbum")!
    #else
        // 要放一张正方形的图，否则会自动加上白色背景
        static var defaultImage = UIImage(imageLiteralResourceName: "DefaultAlbum")
    #endif

    @Published var asset: PlayAsset?
    @Published var playing: Bool = false
    @Published var mode: PlayMode = .Order
    @Published var error: PlayManError? = nil

    let emoji = "💃"
    var delegate: PlayManDelegate?
    var audioWorker: AudioWorker = AudioWorker(delegate: nil)
    var videoWorker: VideoWorker = VideoWorker()
    var verbose = true
    var queue = DispatchQueue(label: "PlayMan", qos: .userInteractive)
    var worker: SuperPlayWorker {
        guard let asset = asset, asset.isNotFolder() else {
            return audioWorker
        }

        return asset.isVideo() ? videoWorker : audioWorker
    }

    var hasError: Bool { error != nil }
    var isAudioWorker: Bool { (self.worker as? AudioWorker) != nil }
    var isVideoWorker: Bool { (self.worker as? VideoWorker) != nil }
    var duration: TimeInterval { worker.duration }
    var currentTime: TimeInterval { worker.currentTime }
    var leftTime: TimeInterval { duration - currentTime }
    var state: PlayState { worker.state }
    var url: URL? { state.getURL() }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }

    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    // MARK: 初始化

    init(verbose: Bool = true, delegate: PlayManDelegate?) {
        super.init()

        self.audioWorker.delegate = self
        self.delegate = delegate

        Task {
            onCommand()
        }
    }
}

// MARK: 播放模式

extension PlayMan {
    func switchMode(verbose: Bool = true) {
        mode = mode.switchMode()
    }
}

// MARK: 播放控制

extension PlayMan {
    func toggleLike() {
        self.asset?.like.toggle()
    }

    func seek(_ to: TimeInterval) {
        self.worker.goto(to)
        setPlayingInfo()
    }

    func play(_ asset: PlayAsset? = nil, reason: String = "", verbose: Bool) {
        if !Thread.isMainThread {
            assert(false, "PlayMan.play 必须在主线程调用")
        }

        self.error = nil

        if let asset = asset {
            if verbose {
                os_log("\(self.t)Play 🔊「\(asset.fileName)」🐛 \(reason)")
            }
            self.asset = asset
        }

        guard let currentAsset = self.asset else {
            self.stop(reason: "Play.NoAsset", verbose: true)
            self.error = .NoAsset
            return
        }

        if currentAsset.isDownloading {
            self.stop(reason: "Play.Downloading", verbose: true)
            self.error = .Downloading
            return
        }

        if currentAsset.isNotDownloaded {
            self.stop(reason: "Play.NotDownloaded", verbose: true)
            self.error = .NotDownloaded
            return
        }

        if asset != nil {
            do {
                try self.worker.prepare(asset, reason: reason, verbose: true)
            } catch {
                self.error = .PrepareFailed(error)
                return
            }
        }

        do {
            try self.worker.play()
            self.playing = true
        } catch {
            self.error = .PlayFailed(error)
            return
        }
    }

    func pause(verbose: Bool) throws {
        if verbose {
            os_log("\(self.t)Pause ⏸️⏸️⏸️")
        }

        try self.worker.pause(verbose: verbose)
        self.playing = false
    }

    func stop(reason: String, verbose: Bool) {
        if verbose {
            os_log("\(self.t)Stop ⏹️⏹️⏹️ 🐛 \(reason)")
        }
        self.worker.stop(reason: reason, verbose: verbose)
        self.playing = false
    }

    func toggle() throws {
        if playing {
            try self.pause(verbose: true)
        } else {
            self.play(reason: "Toggle", verbose: true)
        }
    }

    func prev() {
        self.delegate?.onPlayPrev(current: self.asset)
    }

    func next() {
        self.delegate?.onPlayNext(current: self.asset)
    }

    func setMode(_ mode: PlayMode) {
        if self.mode == mode {
            return
        }

        self.mode = mode
    }

    func getMode() -> PlayMode {
        self.mode
    }
}

// MARK: 媒体中心

extension PlayMan {
    var c: MPRemoteCommandCenter {
        MPRemoteCommandCenter.shared()
    }

    private func setPlayingInfo(verbose: Bool = false) {
        let center = MPNowPlayingInfoCenter.default()
        let artist = "Cisum"
        let title = asset?.fileName ?? ""
        let duration: TimeInterval = self.duration
        let currentTime: TimeInterval = self.currentTime
        let image = asset?.getMediaCenterImage() ?? Self.defaultImage

        if verbose {
            os_log("\(self.t)📱📱📱 Update -> \(self.state.des)")
            os_log("\(self.t)📱📱📱 Update -> Title: \(title)")
            os_log("\(self.t)📱📱📱 Update -> Duration: \(duration)")
            os_log("\(self.t)📱📱📱 Update -> Playing: \(self.playing)")
        }

        center.playbackState = self.playing ? .playing : .paused

        if self.playing == false {
            center.playbackState = .stopped
        }

        center.nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
                #if os(macOS)
                    image.size = size
                #endif

                return image
            }),
        ]

        if verbose {
            // unknown = 0
            // playing = 1
            // paused = 2
            // stopped = 3
            // interrupted = 4
            os_log("\(self.t)📱📱📱 playbackState -> \(center.playbackState.rawValue)")
        }

        let like = asset?.like ?? false
        if verbose {
            os_log("\(self.t)setPlayingInfo like -> \(like)")
        }
        c.likeCommand.isActive = like
    }
}

// MARK: Event Names

extension Notification.Name {
    static let PlayManPlay = Notification.Name("PlayManPlay")
    static let PlayManPause = Notification.Name("PlayManPause")
    static let PlayManStop = Notification.Name("PlayManStop")
    static let PlayManNext = Notification.Name("PlayManNext")
    static let PlayManRandomNext = Notification.Name("PlayManRandomNext")
    static let PlayManPrev = Notification.Name("PlayManPrev")
    static let PlayManToggle = Notification.Name("PlayManToggle")
    static let PlayManLike = Notification.Name("PlayManLike")
    static let PlayManDislike = Notification.Name("PlayManDislike")
    static let PlayManStateChange = Notification.Name("PlayManStateChange")
    static let PlayManModeChange = Notification.Name("PlayManModeChange")
}

// MARK: Event Handlers

extension PlayMan {
    nonisolated func onPlayFinished(verbose: Bool) {
        if verbose {
            os_log("\(self.t)Play finished: \(self.mode.description)")
        }

        switch mode {
        case .Order:
            self.next()
        case .Loop:
            self.play(verbose: verbose)
        case .Random:
            break
        }
    }

    // 接收控制中心的指令
    func onCommand() {
        c.nextTrackCommand.addTarget { _ in
            self.next()

            return .success
        }

        c.previousTrackCommand.addTarget { _ in
            self.prev()

            return .success
        }

        c.pauseCommand.addTarget { _ in
            try? self.pause(verbose: true)

            return .success
        }

        c.playCommand.addTarget { _ in
            os_log("\(self.t)播放")
            self.play(reason: "PlayCommand", verbose: true)

            return .success
        }

        c.stopCommand.addTarget { _ in
            os_log("\(self.t)停止")

            self.worker.stop(reason: "StopCommand", verbose: true)

            return .success
        }

        c.likeCommand.addTarget { _ in
            os_log("\(self.t)点击了喜欢按钮")

            self.toggleLike()

            self.c.likeCommand.isActive = self.asset?.like ?? false
            self.c.dislikeCommand.isActive = self.asset?.notLike ?? true

            return .success
        }

        c.ratingCommand.addTarget { _ in
            os_log("\(Logger.isMain)评分")

            return .success
        }

        c.changeRepeatModeCommand.addTarget { _ in
            os_log("\(self.t)changeRepeatModeCommand")

            return .success
        }

        c.changePlaybackPositionCommand.addTarget { e in
            os_log("\(self.t)changePlaybackPositionCommand")
            guard let event = e as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let positionTime = event.positionTime // 获取当前的播放进度时间

            // 在这里处理当前的播放进度时间
            os_log("Current playback position: \(positionTime)")
            self.seek(positionTime)

            return .success
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
