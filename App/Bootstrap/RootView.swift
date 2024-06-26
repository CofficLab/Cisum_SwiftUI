import OSLog
import SwiftUI

struct RootView: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var dbLocal: DB

    var label: String { "\(Logger.isMain)✈️ RootView::" }
    var verbose: Bool = true
    var dbSynced = DBSynced(Config.getSyncedContainer)

    var body: some View {
        Config.rootBackground
            .task {
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
            .task {
                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif
            }
            .task(priority: .background) {
                if verbose {
                    os_log("\(self.label)执行后台任务")
                }

                Task.detached(
                    priority: .background,
                    operation: {
                        if let url = await playMan.asset?.url {
                            await dataManager.disk.downloadNextBatch(url, reason: "BootView")
                        }
                    })

                Task.detached(operation: {
                    await self.onAppOpen()
                })
            }
    }

    func onAppOpen() {
        Task {
            let uuid = Config.getDeviceId()
            let audioCount = dataManager.disk.getTotal()

            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        }
    }

    // MARK: 恢复上次播放的

    func restore(verbose: Bool = true) {
        playMan.mode = PlayMode(rawValue: Config.currentMode) ?? playMan.mode

        if let currentAudioId = Config.currentAudio {
            if verbose {
                os_log("\(label)上次播放 -> \(currentAudioId.lastPathComponent)")
            }

            Task {
                if let currentAudio = await self.dbLocal.findAudio(currentAudioId) {
                    playMan.prepare(currentAudio.toPlayAsset())
                } else if let current = await self.dbLocal.first() {
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

                Task {
                    dataManager.disk.download(next.url, reason: "Next")
                }
            } else {
                playMan.stop()
            }
        } else {
            Task {
                if let i = await dbLocal.nextOf(asset.url) {
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

        if appManager.dbViewType == .Tree {
            if let prev = DiskFile(url: asset.url).prev() {
                if playMan.isPlaying || manual == false {
                    playMan.play(prev.toPlayAsset(), reason: "在播放时或自动触发上一首")
                } else {
                    playMan.prepare(prev.toPlayAsset())
                }

                Task {
                    dataManager.disk.download(prev.url, reason: "Prev")
                }
            } else {
                playMan.stop()
            }
        } else {
            Task {
                if let i = await self.dbLocal.pre(asset.url) {
                    if self.playMan.isPlaying {
                        self.playMan.play(i.toPlayAsset(), reason: "在播放时触发了上一首")
                    } else {
                        playMan.prepare(i.toPlayAsset())
                    }
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
                    await self.dbLocal.increasePlayCount(asset.url)
                }
            case let .Error(error, _):
                appManager.error = error
            case .Stopped, .Finished:
                break
            default:
                break
            }
        }

        Config.setCurrentURL(state.getAsset()?.url)
    }

    func toggleLike() {
        if let url = playMan.asset?.url {
            Task {
                await self.dbLocal.toggleLike(url)
            }

            //            self.c.likeCommand.isActive = audio.dislike
            //            self.c.dislikeCommand.isActive = audio.like
        }
    }
}
