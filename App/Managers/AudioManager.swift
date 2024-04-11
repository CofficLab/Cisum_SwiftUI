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
    @Published var audio: Audio?
    @Published var playerError: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var lastUpdatedAt: Date = .now
    @Published var networkOK = true

    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var title: String { audio?.title ?? "[无]" }
    private var rootDir: URL = AppConfig.cloudDocumentsDir

    var db: DB = .init(AppConfig.getContainer())
    var dbFolder = DBFolder()
    var isEmpty: Bool { audio == nil }
    var player: AVAudioPlayer = .init()
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }

    override init() {
        os_log("🚩 AudioManager::初始化")
        super.init()
        restore()

        dbPrepare()
        checkNetworkStatus()
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
        os_log("\(Logger.isMain)🚩 AudioManager::restore")
        let currentMode = PlayMode(rawValue: AppConfig.currentMode)
        self.mode = currentMode ?? self.mode

        if let currentAudioId = AppConfig.currentAudio, audio == nil {
            Task {
                if let currentAudio = await self.db.find(currentAudioId) {
                    await self.setCurrent(currentAudio, reason: "初始化，恢复上次播放的")
                } else if let current = self.db.getFirstValid() {
                    await self.setCurrent(current, reason: "初始化，播放第一个")
                } else {
                    os_log("\(Logger.isMain)🚩 AudioManager::restore nothing t o play")
                }
            }
        }
    }

    // MARK: 设置当前的

    @MainActor func setCurrent(_ audio: Audio, play: Bool? = nil, reason: String) {
        os_log("\(Logger.isMain)🍋 ✨ AudioManager::setCurrent to \(audio.title) 🐛 \(reason)")

        self.audio = audio
        try? updatePlayer(play: play ?? player.isPlaying)
        self.errorCheck()

        Task {
            // 下载当前的
            await self.db.download(audio, reason: "SetCurrent")
            self.errorCheck()

            // 下载接下来的
            await db.downloadNext(audio, reason: "触发了下一首")

            // 将当前播放的歌曲存储下来，下次打开继续
            AppConfig.setCurrentAudio(audio)
            
            // 播放次数增加
            await db.increasePlayCount(audio)
        }
    }

    // MARK: 跳转到某个时间

    func gotoTime(time: TimeInterval) {
        player.currentTime = time
        updateState()
    }

    // MARK: 播放指定的

    @MainActor func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)🔊 AudioManager::play \(audio.title)")

        setCurrent(audio, play: true, reason: reason)
    }

    func resume() {
        player.play()
        updateState()
    }

    // MARK: 暂停

    func pause() {
        player.pause()
        updateState()
    }

    // MARK: 停止

    func stop() {
        os_log("\(Logger.isMain)🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
        updateState()
    }

    // MARK: 切换

    @MainActor func toggle() {
        if self.getError() != nil {
            os_log("\(Logger.isMain)🍋 AudioManager::Toggle 取消，因为存在PlayError")
            return
        }

        if player.isPlaying {
            pause()
        } else {
            resume()
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
                await self.setCurrent(i, reason: "触发了上一首")
            }
        }
    }

    // MARK: Next

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::next ⬇️ \(manual ? "手动触发" : "自动触发")")

        if mode == .Loop && manual == false {
            return self.resume()
        }

        guard let audio = audio else {
            return
        }

        Task {
            if let i = db.nextOf(audio) {
                await setCurrent(i, play: player.isPlaying || manual == false, reason: "触发了下一首")
            } else {
                self.stop()
            }
        }
    }

    func trash(_ audio: Audio) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::trash 🗑️ \(audio.title)")

        if self.audio?.url == audio.url {
            try next(manual: true)
        }

        Task {
            await db.trash(audio)
        }
    }
    
    // MARK: 更新状态
    
    func updateState() {
        self.lastUpdatedAt = .now
        self.errorCheck()
        
        Task {
            MediaPlayerManager.setNowPlayingInfo(audioManager: self)
        }
    }
}

// MARK: 播放模式

extension AudioManager {
    // MARK: 切换播放模式

    func switchMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        self.mode = self.mode.switchMode()

        callback(mode)

        Task {
            if mode == .Random {
                await self.db.sortRandom(audio)
            }

            if mode == .Order {
                await db.sort(audio)
            }
        }
    }

    func checkNetworkStatus() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.networkOK = true
                } else {
                    self.networkOK = false
                }

                self.checkError()
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    // MARK: 检查错误

    func clearError() {
        main.async {
            self.playerError = nil
        }
    }
    
    func checkError() {
        _ = errorCheck()
    }
    
    func getError() -> Error? {
        errorCheck()
    }

    func errorCheck() -> Error? {
        guard let audio = audio else {
            return setError(SmartError.NoAudioInList)
        }

        if audio.isNotExists {
            return setError(SmartError.NotExists)
        }

        if audio.isNotDownloaded {
            Task {
                if networkOK == false {
                    _ = setError(SmartError.NetworkError)
                } else {
                    await db.download(audio, reason: "errorCheck")
                }
            }

            return setError(SmartError.NotDownloaded)
        }

        if audio.isDownloading {
            return setError(SmartError.Downloading)
        }

        if audio.isNotSupported {
            return setError(SmartError.FormatNotSupported(audio.ext))
        }
        
        return setError(nil)
    }

    func setError(_ e: Error?) -> Error? {
        main.async {
            self.playerError = e
        }
        
        return e
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
                os_log("\(Logger.isMain)🍋 🔊 AudioManager::UpdatePlayer play")
                self.player.play()
            }
            
            self.updateState()
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

        if self.errorCheck() != nil {
            os_log("\(Logger.isMain)🚩 AudioManager::初始化空播放器，因为存在PlayError")
            return AVAudioPlayer()
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
    @MainActor func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
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
    }.modelContainer(AppConfig.getContainer())
}
