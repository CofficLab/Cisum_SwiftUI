import OSLog
import SwiftUI

struct RootView: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var videoMan: VideoWorker
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager
    @EnvironmentObject var dbLocal: DB

    var verbose: Bool = true
    var dbSynced = DBSynced(Config.getSyncedContainer)

    var label: String { "\(Logger.isMain)✈️ RootView::" }
    var disk: any Disk { data.disk }

    var body: some View {
        Config.rootBackground
            // MARK: Alert
        
            .alert(isPresented: $app.showAlert, content: {
                Alert(title: Text(app.alertMessage))
            })

            // MARK: 场景变化

            .onChange(of: data.disk.root, {
                playMan.stop()

                os_log("\(self.label)Disk已变为：\(data.disk.name)")
                restore(reason: "Disk Changed")
            })

            // MARK: 版本升级操作

            .onAppear {
                Migrate().migrateTo25(dataManager: data)
            }
            .ignoresSafeArea()
            .toolbar(content: {
                ToolbarItem(placement: .navigation, content: {
                    if Config.isDebug {
                        BtnScene()
                    }
                })

                // MARK: 工具栏

                if let asset = playMan.asset {
                    ToolbarItemGroup(placement: .cancellationAction, content: {
                        Spacer()
                        if data.appScene == .Music {
                            BtnLike(asset: asset, autoResize: false)
                        }

                        BtnShowInFinder(url: asset.url, autoResize: false)

                        if data.appScene == .Music {
                            BtnDel(assets: [asset], autoResize: false)
                        }
                    })
                }
            })
            .task {
                restore(reason: "First Launch")

                playMan.onGetNextOf = { asset in
                    self.getNextOf(asset)
                }

                playMan.onGetPrevOf = { asset in
                    self.getPrevOf(asset)
                }

                playMan.onGetChildren = { asset in
                    if let children = DiskFile(url: asset.url).children {
                        return children.map({ $0.toPlayAsset() })
                    }

                    return []
                }

                playMan.onStateChange = { state in
                    self.onStateChanged(state)
                }

                playMan.onToggleLike = {
                    self.toggleLike()
                }

                playMan.onToggleMode = {
                    Task {
                        if verbose {
                            os_log("\(self.label)切换播放模式")
                        }

                        if playMan.mode == .Random {
                            await dbLocal.sortRandom(playMan.asset?.url as URL?)
                        }

                        if playMan.mode == .Order {
                            await dbLocal.sort(playMan.asset?.url as URL?)
                        }
                    }
                }
            }
            .task {
                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif
            }
            .task(priority: .background) {
                if verbose {
                    os_log("\(self.label)🐎🐎🐎 执行后台任务")
                }

                Task.detached(
                    priority: .background,
                    operation: {
                        if let url = await playMan.asset?.url {
                            await disk.downloadNextBatch(url, reason: "BootView")
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
            let audioCount = disk.getTotal()

            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        }
    }

    // MARK: 恢复上次播放的

    func restore(reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(label)👻👻👻 Restore because of \(reason)")
        }

        playMan.mode = PlayMode(rawValue: Config.currentMode) ?? playMan.mode

        Task {
            let currentURL = await dbSynced.getSceneCurrent(data.appScene, reason: "Restore")

            if let url = currentURL {
                if verbose {
                    os_log("\(label)上次播放 -> \(url.lastPathComponent)")
                }

                playMan.prepare(PlayAsset(url: url))
            } else {
                if verbose {
                    os_log("\(label)无上次播放的音频，尝试播放第一个(\(data.disk.name))")
                }

                playMan.prepare(data.first())
            }
        }
    }

    // MARK: Next

    func getNextOf(_ asset: PlayAsset?) -> PlayAsset? {
        guard let asset = asset else {
            return nil
        }

        if data.appScene != .Music {
            return DiskFile(url: asset.url).nextDiskFile()?.toPlayAsset()
        } else {
            return dbLocal.getNextOf(asset.url)?.toPlayAsset()
        }
    }

    // MARK: Prev

    func getPrevOf(_ asset: PlayAsset?) -> PlayAsset? {
        guard let asset = asset else {
            return nil
        }

        if data.appScene != .Music {
            return DiskFile(url: asset.url).prevDiskFile()?.toPlayAsset()
        } else {
            return dbLocal.getPrevOf(asset.url)?.toPlayAsset()
        }
    }

    // MARK: PlayState Changed

    func onStateChanged(_ state: PlayState, verbose: Bool = true) {
        DispatchQueue.main.async {
            if verbose {
                os_log("\(label)播放状态变了 -> \(state.des)")
            }

            app.error = state.getError()
            Task {
                await self.dbLocal.increasePlayCount(state.getPlayingAsset()?.url)
                await dbSynced.updateSceneCurrent(data.appScene, currentURL: state.getURL())
            }
        }
    }

    func toggleLike() {
        guard let asset = playMan.asset else {
            return
        }

        Task {
            await self.dbLocal.toggleLike(asset.url)
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
