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

class PlayMan: NSObject, ObservableObject, SuperLog, SuperThread {
    // MARK: 成员

    static var label = "💃 PlayMan::"
    #if os(macOS)
        static var defaultImage = NSImage(named: "DefaultAlbum")!
    #else
        // 要放一张正方形的图，否则会自动加上白色背景
        static var defaultImage = UIImage(imageLiteralResourceName: "DefaultAlbum")
    #endif

    let emoji = "💃"
    var audioWorker: AudioWorker
    var videoWorker: VideoWorker
    var verbose = false
    var queue = DispatchQueue(label: "PlayMan", qos: .userInteractive)
    var worker: PlayWorker {
        guard let asset = asset, asset.isNotFolder() else {
            return audioWorker
        }

        return asset.isVideo() ? videoWorker : audioWorker
    }

    var asset: PlayAsset?
    var mode: PlayMode = .Order
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

    init(verbose: Bool = true) {
        self.audioWorker = AudioWorker()
        self.videoWorker = VideoWorker()

        super.init()

        self.audioWorker.onStateChange = { state in
            DispatchQueue.main.async {
                self.setPlayingInfo()
                self.asset = state.getAsset()
                self.emitPlayStateChange(state)

                if state.isFinished {
                    os_log("\(self.t)播放完成，自动播放下一个")
                    self.next()
                }
            }
        }

        self.videoWorker.onStateChange = { state in
            DispatchQueue.main.async {
                self.setPlayingInfo()
                self.asset = state.getAsset()
                self.emitPlayStateChange(state)

                if state.isFinished {
                    os_log("\(self.t)播放完成，自动播放下一个")
                    self.next()
                }
            }
        }

        Task {
            onCommand()
        }
    }
}

// MARK: 播放模式

extension PlayMan {
    func switchMode(verbose: Bool = true) {
        mode = mode.switchMode()
        Config.setCurrentMode(mode)
        self.emitPlayModeChange(mode)
    }
}

// MARK: 播放控制

extension PlayMan {
    func toggleLike() {
        self.asset?.like.toggle()
        self.emitPlayLike()
    }

    func goto(_ time: TimeInterval) {
        self.worker.goto(time)
        setPlayingInfo()
    }

    func prepare(_ asset: PlayAsset?) {
        self.worker.prepare(asset)
    }

    // MARK: Play

    func play(_ asset: PlayAsset, reason: String) {
            os_log("\(self.t)Play \(asset.fileName) (\(asset.isAudio() ? "Audio" : "Video")) 🐛 \(reason)")

            if asset.isFolder() {
                guard let first = self.onGetChildren(asset).first else {
                    return self.worker.setError(SmartError.NoChildrenAudio, asset: asset)
                }

                self.asset = first
            } else {
                self.asset = asset
            }

            self.worker.play(self.asset!, reason: reason)
    }

    func play() {
        self.worker.play()
    }

    func resume(reason: String) {
        os_log("\(self.t)Resume while current is \(self.state.des)")

        guard let asset = self.asset else {
            return
        }

        if asset.isFolder() {
            guard let first = self.onGetChildren(asset).first else {
                return self.worker.setError(SmartError.NoNextAudio, asset: asset)
            }

            self.asset = first
            self.worker.play(self.asset!, reason: "Resum")
        } else {
            self.worker.resume()
        }
    }

    func pause() {
        self.worker.pause()
    }

    func stop() {
        self.worker.stop()
    }

    func toggle() {
        if isPlaying {
            self.pause()
        } else {
            self.resume(reason: "Toggle")
        }
    }

    // MARK: Prev

    func prev() {
        self.emitPlayPrev(self.asset)
    }

    // MARK: Next

    func next() {
        self.emitPlayNext(self.asset)
    }
}

// MARK: 播放状态

extension PlayMan {
    var isReady: Bool {
        self.state.isReady
    }

    var isPlaying: Bool {
        self.state.isPlaying
    }

    var isStopped: Bool {
        self.state.isStopped
    }

    var isNotPlaying: Bool {
        !isPlaying
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
            os_log("\(self.t)📱📱📱 Update -> Playing: \(self.isPlaying)")
        }

        center.playbackState = isPlaying ? .playing : .paused
        center.playbackState = isStopped ? .stopped : .paused
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

        let like = asset?.like ?? false
        if verbose {
            os_log("\(self.t)setPlayingInfo like -> \(like)")
        }
        c.likeCommand.isActive = like
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
            self.pause()

            return .success
        }

        c.playCommand.addTarget { _ in
            os_log("\(self.t)播放")
            self.resume(reason: "PlayCommand")

            return .success
        }

        c.stopCommand.addTarget { _ in
            os_log("\(self.t)停止")

            self.worker.stop()

            return .success
        }

        // MARK: Like

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
            self.goto(positionTime)

            return .success
        }
    }
}

// MARK: Event 

extension Notification.Name {
    static let PlayManPlay = Notification.Name("PlayManPlay")
    static let PlayManPause = Notification.Name("PlayManPause")
    static let PlayManStop = Notification.Name("PlayManStop")
    static let PlayManNext = Notification.Name("PlayManNext")
    static let PlayManPrev = Notification.Name("PlayManPrev")
    static let PlayManToggle = Notification.Name("PlayManToggle")
    static let PlayManLike = Notification.Name("PlayManLike")
    static let PlayManDislike = Notification.Name("PlayManDislike")
    static let PlayManStateChange = Notification.Name("PlayManStateChange")
    static let PlayManModeChange = Notification.Name("PlayManModeChange")
}

extension PlayMan {
    func emitPlayStart() {
        NotificationCenter.default.post(name: .PlayManPlay, object: self)
    }

    func emitPlayPause() {
        NotificationCenter.default.post(name: .PlayManPause, object: self)
    }

    func emitPlayStop() {
        NotificationCenter.default.post(name: .PlayManStop, object: self)
    }
    
    func emitPlayNext(_ asset: PlayAsset?) {
        NotificationCenter.default.post(name: .PlayManNext, object: self, userInfo: ["asset": asset])
    }

    func emitPlayPrev(_ asset: PlayAsset?) {
        NotificationCenter.default.post(name: .PlayManPrev, object: self, userInfo: ["asset": asset])
    }
    
    func emitPlayToggle() {
        NotificationCenter.default.post(name: .PlayManToggle, object: self)
    }

    func emitPlayLike() {
        NotificationCenter.default.post(name: .PlayManLike, object: self)
    }

    func emitPlayDislike() {
        NotificationCenter.default.post(name: .PlayManDislike, object: self)
    }

    func emitPlayModeChange(_ mode: PlayMode) {
        NotificationCenter.default.post(name: .PlayManModeChange, object: self, userInfo: ["mode": mode])
    }

    func emitPlayStateChange(_ state: PlayState) {
        let verbose = false
        if verbose {
            os_log("\(self.t)emitPlayStateChange 🚀🚀🚀 -> \(state.des)")
        }
        NotificationCenter.default.post(name: .PlayManStateChange, object: self, userInfo: ["state": state])
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
