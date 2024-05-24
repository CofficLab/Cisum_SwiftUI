import AVKit
import Combine
import Foundation
import MediaPlayer
import Network
import OSLog
import SwiftData
import SwiftUI

/// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject {
    static var label: String = "🔊 AudioManager::"

    @Published var error: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var networkOK = true
    @Published var audio: Audio? = nil

    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var rootDir: URL = AppConfig.cloudDocumentsDir
    private var label: String { Logger.isMain + AudioManager.label }

    var db: DB = .init(AppConfig.getContainer)
    var isEmpty: Bool { audio == nil }
    var player = SmartPlayer()
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }
    var showErrorView: Bool { error != nil }
    var showTitleView: Bool { audio != nil }
    var verbose = true

    override init() {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }

        super.init()

        Task {
            checkNetworkStatus()
        }

        Task {
            restore()
        }

        player.onStateChange = { state in
            self.onStateChanged(state)
        }

        Task {
            onCommand()
        }
    }

    func onStateChanged(_ state: SmartPlayer.State, verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)播放状态变了 -> \(state.des)")
        }

        main.async {
            self.audio = self.player.audio
            self.error = nil
        }

        switch state {
        case let .Playing(audio):
            Task {
                await self.db.increasePlayCount(audio)
            }
        case .Finished:
            next()
        case .Stopped:
            break
        case let .Error(error):
            main.async {
                self.error = error
            }
        default:
            break
        }

        setPlayingInfo()
    }

    // MARK: 恢复上次播放的

    func restore() {
        let currentMode = PlayMode(rawValue: AppConfig.currentMode)
        mode = currentMode ?? mode

        if let currentAudioId = AppConfig.currentAudio, audio == nil {
            Task {
                if let currentAudio = await self.db.findAudio(currentAudioId) {
                    self.prepare(currentAudio, reason: "初始化，恢复上次播放的")
                } else if let current = await self.db.first() {
                    self.prepare(current, reason: "初始化，播放第一个")
                } else {
                    os_log("\(self.label)restore nothing to play")
                }
            }
        }
    }

    // MARK: 准备播放

    func prepare(_ audio: Audio?, reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)Prepare \(audio?.title ?? "nil") 🐛 \(reason)")
        }

        player.prepare(audio)

        Task {
            if let a = audio {
                AppConfig.setCurrentAudio(a)
            }
        }
    }

    // MARK: 播放指定的

    func play(_ audio: Audio, reason: String) {
        if verbose {
            os_log("\(self.label)play \(audio.title) 🚀🚀🚀")
        }

        player.play(audio, reason: reason)
    }

    // MARK: 切换

    func toggle() {
        player.toggle()
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws {
        if verbose {
            os_log("\(self.label)prev ⬆️")
        }

        if mode == .Loop && manual == false {
            return
        }

        Task {
            if let i = await self.db.pre(audio) {
                if self.player.isPlaying {
                    self.play(i, reason: "在播放时触发了上一首")
                } else {
                    self.prepare(i, reason: "未播放时触发了上一首")
                }
            }
        }
    }

    // MARK: Next

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) {
        if verbose {
            os_log("\(self.label)next \(manual ? "手动触发" : "自动触发") ⬇️⬇️⬇️")
        }

        if mode == .Loop && manual == false {
            return player.resume()
        }

        guard let audio = audio else {
            return
        }

        Task {
            if let i = await db.nextOf(audio) {
                if player.isPlaying || manual == false {
                    play(i, reason: "在播放时或自动触发下一首")
                } else {
                    prepare(i, reason: "「未播放且手动」触发了下一首")
                }
            } else {
                self.player.stop()
            }
        }
    }
}

// MARK: 播放模式

extension AudioManager {
    // MARK: 切换播放模式

    func switchMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        mode = mode.switchMode()

        callback(mode)

        Task {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)切换播放模式")
            }

            if mode == .Random {
                await self.db.sortRandom(audio)
            }

            if mode == .Order {
                await db.sort(audio)
            }
        }
    }
}

// MARK: 检查错误

extension AudioManager {
    func checkNetworkStatus() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.networkOK = true
                } else {
                    self.networkOK = false
                }
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}

// MARK: 媒体中心

extension AudioManager {
    var c: MPRemoteCommandCenter {
        MPRemoteCommandCenter.shared()
    }

    private func setPlayingInfo() {
        let audio = player.audio
        let player = player.player
        let isPlaying = player.isPlaying
        let center = MPNowPlayingInfoCenter.default()

        let artist = "乐音APP"
        var title = ""
        var duration: TimeInterval = 0
        var currentTime: TimeInterval = 0
        var image = Audio.defaultImage

        if let audio = audio {
            title = audio.title
            duration = player.duration
            currentTime = player.currentTime
            image = audio.getMediaCenterImage()
        }
        
        os_log("\(self.label)📱📱📱 Update -> \(self.player.state.des)")
        os_log("\(self.label)📱📱📱 Update -> Title: \(title)")
        os_log("\(self.label)📱📱📱 Update -> Duration: \(duration)")
        os_log("\(self.label)📱📱📱 Update -> Playing: \(isPlaying)")

        center.playbackState = isPlaying ? .playing : .paused
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

        let like = audio?.like ?? false
        if verbose {
            os_log("\(self.label)setPlayingInfo like -> \(like)")
        }
        c.likeCommand.isActive = like
    }

    // 接收控制中心的指令
    private func onCommand() {
        c.nextTrackCommand.addTarget { _ in
            os_log("\(Logger.isMain)\(self.label)下一首")
            self.next(manual: true)

            return .success
        }

        c.previousTrackCommand.addTarget { _ in
            do {
                try self.prev()
                os_log("\(Logger.isMain)MediaPlayerManager::pre")

                return .success
            } catch let e {
                os_log("\(Logger.isMain)MediaPlayerManager::\(e.localizedDescription)")
                return .noActionableNowPlayingItem
            }
        }

        c.pauseCommand.addTarget { _ in
            self.player.pause()

            return .success
        }

        c.playCommand.addTarget { _ in
            os_log("\(Logger.isMain)\(self.label)播放")
            self.player.resume()

            return .success
        }

        c.stopCommand.addTarget { _ in
            os_log("\(Logger.isMain)\(self.label)停止")

            self.player.stop()

            return .success
        }

        c.likeCommand.addTarget { _ in
            os_log("\(Logger.isMain)\(self.label)点击了喜欢按钮")

            if let audio = self.player.audio {
                Task {
                    await self.db.toggleLike(audio)
                }

                self.c.likeCommand.isActive = audio.dislike
                self.c.dislikeCommand.isActive = audio.like
            }

            return .success
        }

        c.ratingCommand.addTarget { _ in
            os_log("\(Logger.isMain)评分")

            return .success
        }

        c.changeRepeatModeCommand.addTarget { _ in
            os_log("\(Logger.isMain)changeRepeatModeCommand")

            return .success
        }

        c.changePlaybackPositionCommand.addTarget { e in
            os_log("\(Logger.isMain)\(self.label)changePlaybackPositionCommand")
            guard let event = e as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let positionTime = event.positionTime // 获取当前的播放进度时间

            // 在这里处理当前的播放进度时间
            os_log("Current playback position: \(positionTime)")
            self.player.goto(positionTime)

            return .success
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer)
}
