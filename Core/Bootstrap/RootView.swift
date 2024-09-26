import OSLog
import SwiftUI

struct RootView: View, SuperLog {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var videoMan: VideoWorker
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var l: LayoutProvider
    @EnvironmentObject var dbLocal: DB

    let emoji = "🌳"
    var verbose: Bool = true
    var dbSynced = DBSynced(Config.getSyncedContainer)

    var body: some View {
        Config.rootBackground

            // MARK: Alert

            .alert(isPresented: $app.showAlert, content: {
                Alert(title: Text(app.alertMessage))
            })

            // MARK: 场景变化

            .onChange(of: l.current.id, {
                playMan.stop()
            })

            .ignoresSafeArea()
            .toolbar(content: {
                // ToolbarItem(placement: .navigation) {
                //     BtnScene()
                // }

                // MARK: 工具栏

                if let asset = playMan.asset {
                    ToolbarItemGroup(placement: .cancellationAction, content: {
                        Spacer()
                        if l.current.isAudioApp {
                            BtnLike(asset: asset, autoResize: false)
                        }

                        BtnShowInFinder(url: asset.url, autoResize: false)

                        if l.current.isAudioApp {
                            BtnDel(assets: [asset], autoResize: false)
                        }
                    })
                }
            })
            .task {
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
                            os_log("\(self.t)切换播放模式")
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
                    os_log("\(self.t)🐎🐎🐎 执行后台任务")
                }

                Task.detached(operation: {
                    await self.onAppOpen()
                })
            }
    }

    func onAppOpen() {
//        Task {
//            let uuid = Config.getDeviceId()
//            let audioCount = disk.getTotal()
//
//            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
//        }
    }

    // MARK: Next

    func getNextOf(_ asset: PlayAsset?) -> PlayAsset? {
        guard let asset = asset else {
            return nil
        }

//        if data.appScene != .Music {
        return DiskFile(url: asset.url).nextDiskFile()?.toPlayAsset()
//        } else {
//            return dbLocal.getNextOf(asset.url)?.toPlayAsset()
//        }
    }

    // MARK: Prev

    func getPrevOf(_ asset: PlayAsset?) -> PlayAsset? {
        guard let asset = asset else {
            return nil
        }

//        if data.appScene != .Music {
        return DiskFile(url: asset.url).prevDiskFile()?.toPlayAsset()
//        } else {
//            return dbLocal.getPrevOf(asset.url)?.toPlayAsset()
//        }
    }

    // MARK: PlayState Changed

    func onStateChanged(_ state: PlayState, verbose: Bool = true) {
        DispatchQueue.main.async {
            if verbose {
                os_log("\(t)播放状态变了 -> \(state.des)")
            }

            app.error = state.getError()
            Task {
                await self.dbLocal.increasePlayCount(state.getPlayingAsset()?.url)
//                await dbSynced.updateSceneCurrent(data.appScene, currentURL: state.getURL())
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
