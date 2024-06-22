import AVKit
import Combine
import Foundation
import MediaPlayer
import Network
import OSLog
import SwiftData
import SwiftUI

class PlayManager: NSObject, ObservableObject {
    static var label: String = "🔊 AudioManager::"

    @Published var error: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var asset: PlayAsset? = nil

    private var bg = Config.bgQueue
    private var main = Config.mainQueue
    private var label: String { Logger.isMain + PlayManager.label }

    var db: DB
    var isEmpty: Bool { asset == nil }
    var playMan: PlayMan

    init(db: DB, playMan: PlayMan, verbose: Bool = true) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
        
        self.db = db
        self.playMan = playMan

        super.init()

        playMan.onStateChange = { state in
            self.onStateChanged(state)
        }
        
        playMan.onNext = {
            self.next(manual: true)
        }
        
        playMan.onPrev = {
            self.prev(manual: true)
        }
        
        playMan.onToggleLike = {
            self.toggleLike()
        }
    }

    func onStateChanged(_ state: PlayState, verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)播放状态变了 -> \(state.des)")
        }

        main.async {
            self.asset = state.getAsset()
            self.error = nil
            
            switch state {
            case let .Playing(asset):
                Task {
                    await self.db.increasePlayCount(asset.url)
                }
            case .Finished:
                self.next()
            case let .Error(error, _):
                self.error = error
            case .Stopped:
                break
            default:
                break
            }
        }
        
        Config.setCurrentURL(state.getAsset()?.url)
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false, verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)prev ⬆️")
        }

        if mode == .Loop && manual == false {
            return
        }

        Task {
            if let i = await self.db.pre(asset?.url) {
                if self.playMan.isPlaying {
                    self.playMan.play(i.toPlayAsset(), reason: "在播放时触发了上一首")
                } else {
                    playMan.prepare(i.toPlayAsset())
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
            return playMan.resume()
        }

        guard let asset = asset else {
            return
        }

        Task {
            if let i = await db.nextOf(asset.url) {
                if playMan.isPlaying || manual == false {
                    playMan.play(i.toPlayAsset(), reason: "在播放时或自动触发下一首")
                } else {
                    playMan.prepare(i.toPlayAsset())
                }
            } else {
                playMan.stop()
            }
        }
    }
    
    func toggleLike() {
        //            if let audio = self.player.asset?.toAudio() {
        //                Task {
        //                    await self.db.toggleLike(audio)
        //                }
        //
        //                self.c.likeCommand.isActive = audio.dislike
        //                self.c.dislikeCommand.isActive = audio.like
        //            }
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

            if mode == .Random {
                await db.sortRandom(asset?.url as URL?)
            }

            if mode == .Order {
                await db.sort(asset?.url as URL?)
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
