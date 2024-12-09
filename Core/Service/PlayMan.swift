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

@MainActor
class PlayMan: NSObject, ObservableObject, SuperLog, SuperThread {
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

    let emoji = "💃"
    var delegate: PlayManDelegate?
    var audioWorker: AudioWorker
    var videoWorker: VideoWorker
    var verbose = true
    var queue = DispatchQueue(label: "PlayMan", qos: .userInteractive)
    var worker: SuperPlayWorker {
        guard let asset = asset, asset.isNotFolder() else {
            return audioWorker
        }

        return asset.isVideo() ? videoWorker : audioWorker
    }

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

    // MARK: 告诉我如何获取播放资源

    var onGetChildren: (_ asset: PlayAsset) -> [PlayAsset] = { asset in
        os_log("\(PlayMan.label)GetChildrenOf -> \(asset.title)")
        return []
    }

    // MARK: 初始化

    init(verbose: Bool = true, delegate: PlayManDelegate?) {
        self.audioWorker = AudioWorker()
        self.videoWorker = VideoWorker()
        self.delegate = delegate

        super.init()

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

    func play(_ asset: PlayAsset? = nil, reason: String = "", verbose: Bool = false) throws {
        if !Thread.isMainThread {
            assert(false, "PlayMan.play 必须在主线程调用")
        }

        if let asset = asset {
            if verbose {
                os_log("\(self.t)Play 🔊「\(asset.fileName)」🐛 \(reason)")
            }
            self.asset = asset
        }

        guard let currentAsset = self.asset else {
            self.stop(reason: "Play.NoAsset", verbose: true)
            throw PlayManError.NoAsset
        }

        if currentAsset.isDownloading {
            self.stop(reason: "Play.Downloading", verbose: true)
            throw PlayManError.Downloading
        }

        if currentAsset.isNotDownloaded {
            self.stop(reason: "Play.NotDownloaded", verbose: true)
            throw PlayManError.NotDownloaded
        }
        
        if asset != nil {
            try self.worker.prepare(asset, reason: reason, verbose: true)
        }
        
        try self.worker.play()
        self.playing = true
    }

    func resume(reason: String, verbose: Bool) throws {
        guard let asset = self.asset else {
            throw PlayManError.NoAsset
        }

        if asset.isFolder() {
            guard let first = self.onGetChildren(asset).first else {
                return self.worker.setError(SmartError.NoNextAudio, asset: asset)
            }

            self.asset = first
            try self.play(self.asset!, reason: "Resum", verbose: true)
        } else {
            try self.play()
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
            os_log("\(self.t)Stop 🐛 \(reason)")
        }
        self.worker.stop(reason: reason, verbose: verbose)
    }

    func toggle() throws {
        if playing {
            try self.pause(verbose: true)
        } else {
            try self.resume(reason: "Toggle", verbose: true)
        }
    }

    // MARK: Prev

    func prev() {
        self.delegate?.onPlayPrev(current: self.asset)
    }

    // MARK: Next

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

// MARK: 播放状态

extension PlayMan {
    var isReady: Bool {
        self.state.isReady
    }

    var isStopped: Bool {
        self.state.isStopped
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
            os_log("\(self.t)📱📱📱 Update -> Stopped: \(self.isStopped)")
        }

        center.playbackState = self.playing ? .playing : .paused

        if self.isStopped {
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
    func onPlayFinished() {
        let verbose = false
        switch mode {
        case .Order:
            if verbose {
                os_log("\(self.t)播放完成，模式为：\(self.mode.description)，自动播放下一个")
            }
            self.next()
        case .Loop:
            if verbose {
                os_log("\(self.t)循环播放")
            }
            try? play()
        case .Random:
            if verbose {
                os_log("\(self.t)随机播放")
            }
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
            try? self.resume(reason: "PlayCommand", verbose: true)

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
