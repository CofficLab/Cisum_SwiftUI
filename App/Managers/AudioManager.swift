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
    
    @Published var audio: Audio?
    @Published var playerError: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var networkOK = true

    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var title: String { audio?.title ?? "[无]" }
    private var rootDir: URL = AppConfig.cloudDocumentsDir
    private var label: String { AudioManager.label }

    var db: DB = .init(AppConfig.getContainer())
    var dbFolder = DBFolder()
    var isEmpty: Bool { audio == nil }
    var player = SmartPlayer()
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }

    override init() {
        os_log("\(Logger.isMain)\(AudioManager.label)初始化")
        super.init()
        restore()

        checkNetworkStatus()
        player.onAudioChange = {
            self.audio = $0
        }
        player.onStateChange = { state in
            os_log("\(Logger.isMain)\(AudioManager.label)播放状态变了 \(state.des)")
            switch state {
            case .Finished:
                self.next()
            case .Stopped:
                break
            default:
                break
            }
        }
    }

    // MARK: 恢复上次播放的

    func restore() {
        let currentMode = PlayMode(rawValue: AppConfig.currentMode)
        self.mode = currentMode ?? self.mode

        if let currentAudioId = AppConfig.currentAudio, audio == nil {
            Task {
                if let currentAudio = await self.db.find(currentAudioId) {
                    await self.setCurrent(currentAudio, reason: "初始化，恢复上次播放的")
                } else if let current = self.db.getFirstValid() {
                    await self.setCurrent(current, reason: "初始化，播放第一个")
                } else {
                    os_log("\(Logger.isMain)🚩 AudioManager::restore nothing to play")
                }
            }
        }
    }

    // MARK: 设置当前的

    @MainActor func setCurrent(_ audio: Audio?, play: Bool? = nil, reason: String) {
        os_log("\(Logger.isMain)\(self.label)setCurrent to \(audio?.title ?? "nil") 🐛 \(reason)")

        self.player.audio = audio
        if play == true {
            self.player.play()
        }
        
        self.checkError()

        Task {
            if let a = audio {
                // 下载当前的
                await self.db.download(a, reason: "SetCurrent")
                
                // 下载接下来的
                await db.downloadNext(a, reason: "触发了下一首")

                // 将当前播放的歌曲存储下来，下次打开继续
                AppConfig.setCurrentAudio(a)

                // 播放次数增加
                await db.increasePlayCount(a)
            }
        }
    }

    // MARK: 播放指定的

    @MainActor func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)\(self.label)play \(audio.title)")

        setCurrent(audio, play: true, reason: reason)
    }

    // MARK: 切换

    @MainActor func toggle() {
        if self.getError() != nil {
            os_log("\(Logger.isMain)\(self.label)Toggle 取消，因为存在PlayError")
            return
        }

        player.toggle()
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws {
        os_log("\(Logger.isMain)\(self.label)prev ⬆️")

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
    func next(manual: Bool = false) {
        os_log("\(Logger.isMain)\(self.label)next ⬇️ \(manual ? "手动触发" : "自动触发")")

        if mode == .Loop && manual == false {
            return self.player.resume()
        }

        guard let audio = audio else {
            return
        }

        Task {
            if let i = db.nextOf(audio) {
                await setCurrent(i, play: player.isPlaying || manual == false, reason: "触发了下一首")
            } else {
                self.checkError()
                self.player.stop()
            }
        }
    }

    func trash(_ audio: Audio) throws {
        os_log("\(Logger.isMain)\(self.label)trash 🗑️ \(audio.title)")

        if self.audio?.url == audio.url {
            next(manual: true)
        }

        Task {
            await db.trash(audio)
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

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
