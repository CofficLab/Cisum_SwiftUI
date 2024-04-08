import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftData
import SwiftUI

/// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject {
    @Published var audio: Audio?
    @Published var playerError: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var lastUpdatedAt: Date = .now
    @Published var player: AVAudioPlayer = .init()

    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var title: String { audio?.title ?? "[无]" }
    private var rootDir: URL = AppConfig.cloudDocumentsDir

    var db: DB = .init(AppConfig.getContainer())
    var isEmpty: Bool { audio == nil }
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }

    override init() {
        os_log("🚩 AudioManager::初始化")
        super.init()
        restore()

//        self.dbPrepare()
    }

    func dbPrepare() {
        Task.detached {
            os_log("\(Logger.isMain)🚩 AudioManager::准备数据库")
            await self.db.setOnUpdated { 
                self.main.async {
                    self.lastUpdatedAt = .now
                }

                self.restore()
            }
            await self.db.getAudios()
            await self.db.prepare()
        }
    }

    // MARK: 恢复上次播放的

    func restore() {
        if let currentAudioId = AppConfig.currentAudio, audio == nil {
            Task {
                if let currentAudio = await self.db.find(currentAudioId) {
                    self.setCurrent(currentAudio, reason: "初始化，恢复上次播放的")
                }
            }
        }
    }

    // MARK: 设置当前的

    func setCurrent(_ audio: Audio, play: Bool = false, reason: String) {
        os_log("\(Logger.isMain)🍋 ✨ AudioManager::setCurrent to \(audio.title) 🐛 \(reason)")

        main.async {
            self.audio = audio
            try? self.updatePlayer(play: play)

            // 将当前播放的歌曲存储下来，下次打开继续
            Task {
                AppConfig.setCurrentAudio(audio)
            }
        }
    }

    // MARK: 跳转到某个时间

    func gotoTime(time: TimeInterval) {
        player.currentTime = time
        updateMediaPlayer()
    }

    // MARK: 播放指定的

    func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)🔊 AudioManager::play \(audio.title)")

        if audio.isNotDownloaded {
            playerError = SmartError.NotDownloaded
            Task {
                await self.db.download(audio, reason: "Play")
            }
            return
        }

        playerError = nil
        setCurrent(audio, play: true, reason: reason)
    }

    func resume() {}

    // MARK: 暂停

    func pause() {
        player.pause()
        updateMediaPlayer()
    }

    // MARK: 停止

    func stop() {
        os_log("\(Logger.isMain)🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
    }

    // MARK: 切换

    func toggle() throws {
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
            if let i = await self.db.preOf(audio) {
                main.sync {
                    self.audio = i
                    try? updatePlayer(play: player.isPlaying)
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
            if let i = await self.db.nextOf(audio) {
                main.sync {
                    self.audio = i
                    try? updatePlayer(play: player.isPlaying || manual == false)
                }

                await self.db.downloadNext(i, reason: "触发了下一首")
            }
        }
    }

    private func updateMediaPlayer() {
        Task {
            MediaPlayerManager.setNowPlayingInfo(audioManager: self)
        }
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
                await self.db.sortRandom()
            }

            if mode == .Order {
                await db.sort()
            }
        }
    }
}

// MARK: 控制系统播放器

extension AudioManager {
    func updatePlayer(play: Bool = false) throws {
        guard let audio = audio else {
            os_log("\(Logger.isMain)🍋 AudioManager::UpdatePlayer cancel because audio=nil")
            return
        }

        os_log("\(Logger.isMain)🍋 AudioManager::UpdatePlayer \(audio.title)")

        do {
            playerError = nil
            player = try makePlayer()
            player.delegate = self
            if play {
                player.play()
            }

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
