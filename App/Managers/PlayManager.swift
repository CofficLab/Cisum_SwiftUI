import AVKit
import Combine
import Foundation
import MediaPlayer
import Network
import OSLog
import SwiftData
import SwiftUI

/// 管理播放器的播放、暂停、上一曲、下一曲等操作
class PlayManager: NSObject, ObservableObject {
    static var label: String = "🔊 AudioManager::"

    @Published var error: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var asset: PlayAsset? = nil

    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var label: String { Logger.isMain + PlayManager.label }

    var db: DB = .init(AppConfig.getContainer, reason: "AudioManager")
    var isEmpty: Bool { asset == nil }
    var player = PlayMan()

    init(db: DB, verbose: Bool = true) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
        
        self.db = db

        super.init()

        Task {
            restore()
        }

        player.onStateChange = { state in
            self.onStateChanged(state)
        }

//        Task {
//            onCommand()
//        }
    }

    func onStateChanged(_ state: PlayState, verbose: Bool = false) {
        if verbose {
            os_log("\(self.label)播放状态变了 -> \(state.des)")
        }

        main.async {
            self.asset = self.player.asset
            self.error = nil
        }

        switch state {
        case let .Playing(asset):
            Task {
                await self.db.increasePlayCount(asset.toAudio())
            }
        case .Finished:
            next()
        case .Stopped:
            break
        case let .Error(error, _):
            main.async {
                self.error = error
            }
        default:
            break
        }

//        setPlayingInfo()
    }

    // MARK: 恢复上次播放的

    func restore() {
        let currentMode = PlayMode(rawValue: AppConfig.currentMode)
        mode = currentMode ?? mode

        if let currentAudioId = AppConfig.currentAudio, asset == nil {
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

    func prepare(_ audio: Audio?, reason: String, verbose: Bool = false) {
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

    func play(_ audio: Audio, reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)play \(audio.title) 🚀🚀🚀")
        }

        player.play(audio.toPlayAsset(), reason: reason)
    }

    // MARK: 切换

    func toggle() {
        player.toggle()
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false, verbose: Bool = true) throws {
        if verbose {
            os_log("\(self.label)prev ⬆️")
        }

        if mode == .Loop && manual == false {
            return
        }

        Task {
            if let i = await self.db.pre(asset?.url) {
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
    func next(manual: Bool = false, verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)next \(manual ? "手动触发" : "自动触发") ⬇️⬇️⬇️")
        }

        if mode == .Loop && manual == false {
            return player.resume()
        }

        guard let asset = asset else {
            return
        }

        Task {
            if let i = await db.nextOf(asset.url) {
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

extension PlayManager {
    // MARK: 切换播放模式

    func switchMode(_ callback: @escaping (_ mode: PlayMode) -> Void, verbose: Bool = true) {
        mode = mode.switchMode()

        callback(mode)

        Task {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)切换播放模式")
            }

//            if mode == .Random {
//                await self.db.sortRandom(asset?.url)
//            }
//
//            if mode == .Order {
//                await db.sort(asset?.url)
//            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer)
}
