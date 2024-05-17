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
    var showErrorView: Bool { self.error != nil }
    var showTitleView: Bool { self.audio != nil }
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
    }
    
    func onStateChanged(_ state: SmartPlayer.State) {
        if verbose {
            os_log("\(self.label)播放状态变了 -> \(state.des)")
        }
        
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

    func prepare(_ audio: Audio?, reason: String) {
        if verbose {
            os_log("\(self.label)Prepare \(audio?.title ?? "nil") 🐛 \(reason)")
        }

        self.player.prepare(audio)

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

        self.player.play(audio, reason: reason)
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
                self.prepare(i, reason: "触发了上一首")
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
            return self.player.resume()
        }

        guard let audio = audio else {
            return
        }

        Task {
            if let i = await db.nextOf(audio) {
                if player.isPlaying || manual == false {
                    play(i, reason: "触发下一首")
                } else {
                    prepare(i, reason: "触发了下一首")
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
        self.mode = self.mode.switchMode()

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

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer)
}
