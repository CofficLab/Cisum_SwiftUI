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
    private var label: String { AudioManager.label }

    var db: DB = .init(AppConfig.getContainer())
    var isEmpty: Bool { audio == nil }
    var player = SmartPlayer()
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }
    var showErrorView: Bool { self.error != nil }
    var showTitleView: Bool { self.audio != nil }

    override init() {
        os_log("\(Logger.isMain)\(AudioManager.label)初始化")
        super.init()
        restore()

        checkNetworkStatus()
        player.onStateChange = { state in
            self.onStateChanged(state)
        }
        
        Task {
            prepare(nil, reason: "AudioManager初始化")
        }
    }
    
    func onStateChanged(_ state: SmartPlayer.State) {
        os_log("\(Logger.isMain)\(AudioManager.label)播放状态变了 \(state.des)")
        self.main.async {
            self.audio = self.player.audio
            self.error = nil
        }
        
        switch state {
        case .Playing(let audio):
             Task {
                 await self.db.increasePlayCount(audio)
             }
             case .Finished:
            self.next()
        case .Stopped:
            break
        case .Error(let error):
            self.main.async {
                self.error = error
            }
        default:
            break
        }
    }

    // MARK: 恢复上次播放的

    func restore() {
        let currentMode = PlayMode(rawValue: AppConfig.currentMode)
        self.mode = currentMode ?? self.mode

        if let currentAudioId = AppConfig.currentAudio, audio == nil {
            Task {
                if let currentAudio = await self.db.find(currentAudioId) {
                    self.prepare(currentAudio, reason: "初始化，恢复上次播放的")
                } else if let current = self.db.first() {
                    self.prepare(current, reason: "初始化，播放第一个")
                } else {
                    os_log("\(Logger.isMain)🚩 AudioManager::restore nothing to play")
                }
            }
        }
    }

    // MARK: 准备播放

    func prepare(_ audio: Audio?, play: Bool = false, reason: String) {
        os_log("\(Logger.isMain)\(self.label)Prepare \(audio?.title ?? "nil") 🐛 \(reason)")

        self.player.prepare(audio, play: play)

        Task {
            if let a = audio {
                // 下载当前的和接下来的
                await db.downloadNext(a, reason: "触发了下一首")

                // 将当前播放的歌曲存储下来，下次打开继续
                AppConfig.setCurrentAudio(a)
            }
        }
    }

    // MARK: 播放指定的

    func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)\(self.label)play \(audio.title)")

        prepare(audio, play: true, reason: reason)
    }

    // MARK: 切换

    func toggle() {
        player.toggle()
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws {
        os_log("\(Logger.isMain)\(self.label)prev ⬆️")

        if mode == .Loop && manual == false {
            return
        }

        Task {
            if let i = await self.db.pre(audio) {
                self.prepare(i, reason: "触发了上一首")
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
            if let i = await db.nextOf(audio) {
                prepare(i, play: player.isPlaying || manual == false, reason: "触发了下一首")
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

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
