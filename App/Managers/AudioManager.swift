import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftData
import SwiftUI

/// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published var audio: Audio?
    @Published var playerError: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var lastUpdatedAt: Date = .now

    private var player: AVAudioPlayer = .init()
    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var title: String { audio?.title ?? "[无]" }
    private var rootDir: URL = AppConfig.cloudDocumentsDir

    var db: DB?
    var isEmpty: Bool { audio == nil }
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }

    override init() {
        super.init()
        db = DB(AppConfig.getContainer(), onUpdated: {
            self.main.async {
                self.lastUpdatedAt = .now
            }

            if let currentAudioId = AppConfig.currentAudio, self.audio == nil {
                Task {
                    if let currentAudio = await self.db!.find(currentAudioId) {
                        self.setCurrent(currentAudio, reason: "初始化，恢复上次播放的")
                    }
                }
            }
        })
    }

    // MARK: 设置当前的

    func setCurrent(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)🍋 ✨ AudioManager::setCurrent to \(audio.title) 🐛 \(reason)")
        main.async {
            self.audio = audio
            try? self.updatePlayer()
        }

        Task {
            AppConfig.setCurrentAudio(audio)
        }
    }

    func currentTime() -> TimeInterval {
        return player.currentTime
    }

    func currentTimeDisplay() -> String {
        return DateComponentsFormatter.positional.string(from: currentTime()) ?? "0:00"
    }

    func leftTime() -> TimeInterval {
        return player.duration - player.currentTime
    }

    func leftTimeDisplay() -> String {
        return DateComponentsFormatter.positional.string(from: leftTime()) ?? "0:00"
    }

    func gotoTime(time: TimeInterval) {
        player.currentTime = time
        updateMediaPlayer()
    }

//    func replay() {
//        os_log("\(Logger.isMain)🍋 AudioManager::replay()")
//
//        play(audio!)
//    }

    // MARK: 播放指定的

    func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)🔊 AudioManager::play \(audio.title)")

        if audio.isNotDownloaded {
            playerError = SmartError.NotDownloaded
            Task {
                await self.db?.download(audio, reason: "Play")
            }
            return
        }

        playerError = nil
        setCurrent(audio, reason: reason)
        player.play()
        isPlaying = true
    }

    func resume() {
    }

    // MARK: 暂停

    func pause() {
        player.pause()
        isPlaying = false

        updateMediaPlayer()
    }

    // MARK: 停止

    func stop() {
        os_log("\(Logger.isMain)🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
        duration = 0
        isPlaying = false
    }

    // MARK: 切换

    func togglePlayPause() throws {
        guard let audio = audio else {
            throw SmartError.NoAudioInList
        }

        if isEmpty {
            throw SmartError.NoAudioInList
        }

        if audio.isDownloading {
            throw SmartError.Downloading
        }

        if player.isPlaying {
            pause()
        } else {
            play(audio, reason: "Toggle")
        }
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::prev ⬆️")

        if mode == .Loop && manual == false {
            return
        }

        guard let audio = audio else {
            return
        }

        Task {
            if let i = await self.db!.preOf(audio) {
                main.sync {
                    self.audio = i
                    try? updatePlayer()
                }
            }
        }
    }

    // MARK: Next

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::next ⬇️ \(manual ? "手动触发" : "自动触发")")

        if mode == .Loop && manual == false {
            return
        }

        guard let audio = audio else {
            return
        }

        Task {
            if let i = await self.db!.nextOf(audio) {
                main.sync {
                    self.audio = i
                    try? updatePlayer()
                }

                await self.db?.downloadNext(i, reason: "触发了下一首")
            }
        }
    }

    private func updateMediaPlayer() {
        MediaPlayerManager.setNowPlayingInfo(audioManager: self)
    }

    // 当前的 Audio 是否有效
    private func isValid() -> Bool {
        // 列表为空
        if isEmpty {
            return false
        }

        guard audio != nil else {
            return false
        }

        return true
    }

    private func reset() {
        stop()
        audio = nil
        player = AVAudioPlayer()
    }
}

// MARK: 播放模式

extension AudioManager {
    enum PlayMode {
        case Order
        case Loop
        case Random

        var description: String {
            switch self {
            case .Order:
                return "顺序播放"
            case .Loop:
                return "单曲循环"
            case .Random:
                return "随机播放"
            }
        }
    }

    // MARK: 切换播放模式

    func switchMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        switch mode {
        case .Order:
            mode = .Random
        case .Loop:
            mode = .Order
        case .Random:
            mode = .Loop
        }

        callback(mode)

        Task {
            if mode == .Random {
                await self.db?.sortRandom()
            }

            if mode == .Order {
                await db?.sort()
            }
        }
    }
}

// MARK: 控制系统播放器

extension AudioManager {
    func updatePlayer() throws {
        guard let audio = audio else {
            os_log("\(Logger.isMain)🍋 AudioManager::UpdatePlayer cancel because audio=nil")
            return
        }

        os_log("\(Logger.isMain)🍋 AudioManager::UpdatePlayer \(audio.title)")

        do {
            playerError = nil
            player = try makePlayer()
            player.delegate = self
            duration = player.duration

            updateMediaPlayer()
        } catch let e {
            withAnimation {
                self.stop()
                self.playerError = e
            }

            throw e
        }
    }

    func makePlayer() throws -> AVAudioPlayer {
        os_log("\(Logger.isMain)🚩 AudioManager::初始化播放器")

        guard let audio = audio else {
            os_log("\(Logger.isMain)🚩 AudioManager::初始化播放器失败，因为当前Audio=nil")
            return AVAudioPlayer()
        }

        if audio.isNotDownloaded {
            os_log("\(Logger.isMain)🚩 AudioManager::初始化播放器失败，因为未下载")
            throw SmartError.NotDownloaded
        }

        if audio.isNotSupported {
            throw SmartError.FormatNotSupported(audio.ext)
        }

        os_log("\(Logger.isMain)🚩 AudioManager::初始化播放器开始")

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            let player = try AVAudioPlayer(contentsOf: audio.url)

            return player
        } catch {
            os_log("\(Logger.isMain)初始化播放器失败 ->\(audio.title)->\(error)")

            throw SmartError.PlayFailed
        }
    }
}

// MARK: 接收系统事件

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            os_log("\(Logger.isMain)🍋 AudioManager::播放被打断，更新为暂停状态")
            return pause()
        }

        os_log("\(Logger.isMain)🍋 AudioManager::播放完成，自动播放下一曲")
        do {
            try next(manual: false)
        } catch let e {
            os_log("\(Logger.isMain)‼️ AudioManager::\(e.localizedDescription)")
            self.playerError = e
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        os_log("\(Logger.isMain)audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        os_log("\(Logger.isMain)🍋 AudioManager::audioPlayerBeginInterruption")
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        os_log("\(Logger.isMain)🍋 AudioManager::audioPlayerEndInterruption")
        resume()
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
