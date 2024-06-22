import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label: String { "\(Logger.isMain)🌳 RootView::" }

    var db: DB
    var dbSynced = DBSynced(Config.getSyncedContainer)
    var appManager = AppManager()
    var storeManager = StoreManager()
    var playMan: PlayMan
    var diskManager: DiskManager = DiskManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        db = DB(Config.getContainer, reason: "RootView")
        playMan = PlayMan()
    }

    var body: some View {
        content
            .onAppear {
                restore()

                playMan.onNext = {
                    self.next()
                }

                playMan.onPrev = {
                    self.prev()
                }

                playMan.onStateChange = { state in
                    self.onStateChanged(state)
                }

                playMan.onToggleLike = {
                    self.toggleLike()
                }
            }
            .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
            .blendMode(.normal)
            .task {
                if verbose {
                    os_log("\(self.label)同步数据库")
                }

                await db.startWatch()

                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif
            }
            .task(priority: .background) {
                Config.bgQueue.asyncAfter(deadline: .now() + 0) {
                    if verbose {
                        os_log("\(self.label)执行后台任务")
                    }

                    Task.detached(priority: .background, operation: {
                        await db.prepareJob()
                    })

                    Task.detached(operation: {
                        self.onAppOpen()
                    })
                }
            }
            .background(Config.rootBackground)
            .environmentObject(db)
            .environmentObject(playMan)
            .environmentObject(appManager)
            .environmentObject(storeManager)
            .environmentObject(diskManager)
    }

    func onAppOpen() {
        Task {
            let uuid = Config.getDeviceId()
            let audioCount = await db.getTotalOfAudio()

            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        }
    }

    // MARK: 恢复上次播放的

    func restore(verbose: Bool = true) {
        if verbose {
            os_log("\(label)恢复上次播放")
        }

        playMan.mode = PlayMode(rawValue: Config.currentMode) ?? playMan.mode

        if let currentAudioId = Config.currentAudio {
            if verbose {
                os_log("\(label)上次播放 -> \(currentAudioId.lastPathComponent)")
            }

            Task {
                if let currentAudio = await self.db.findAudio(currentAudioId) {
                    playMan.prepare(currentAudio.toPlayAsset())
                } else if let current = await self.db.first() {
                    playMan.prepare(current.toPlayAsset())
                } else {
                    os_log("\(self.label)restore nothing to play")
                }
            }
        } else {
            if verbose {
                os_log("\(label)无上次播放的音频")
            }
        }
    }

    // MARK: Next

    func next(manual: Bool = false, verbose: Bool = true) {
        if verbose {
            os_log("\(label)next \(manual ? "手动触发" : "自动触发") ⬇️⬇️⬇️")
        }

        if playMan.mode == .Loop && manual == false {
            return playMan.resume()
        }

        guard let asset = playMan.asset else {
            return
        }

        if appManager.dbViewType == .Tree {
            if let next = DiskFile(url: asset.url).next() {
                if playMan.isPlaying || manual == false {
                    playMan.play(next.toPlayAsset(), reason: "在播放时或自动触发下一首")
                } else {
                    playMan.prepare(next.toPlayAsset())
                }
            } else {
                playMan.stop()
            }
        } else {
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
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false, verbose: Bool = true) {
        if verbose {
            os_log("\(label)prev ⬆️")
        }

        if playMan.mode == .Loop && manual == false {
            return
        }

        guard let asset = playMan.asset else {
            return
        }

        Task {
            if let i = await self.db.pre(asset.url) {
                if self.playMan.isPlaying {
                    self.playMan.play(i.toPlayAsset(), reason: "在播放时触发了上一首")
                } else {
                    playMan.prepare(i.toPlayAsset())
                }
            }
        }
    }

    func onStateChanged(_ state: PlayState, verbose: Bool = true) {
        if verbose {
            os_log("\(label)播放状态变了 -> \(state.des)")
        }

        DispatchQueue.main.async {
            appManager.error = nil

            switch state {
            case let .Playing(asset):
                Task {
                    await self.db.increasePlayCount(asset.url)
                }
            case .Finished:
                self.next()
            case let .Error(error, _):
                appManager.error = error
            case .Stopped:
                break
            default:
                break
            }
        }

        Config.setCurrentURL(state.getAsset()?.url)
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

#Preview("App") {
    AppPreview()
}
