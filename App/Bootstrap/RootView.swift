import OSLog
import SwiftUI

struct RootView: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var dbLocal: DB

    var verbose: Bool = true
    var dbSynced = DBSynced(Config.getSyncedContainer)

    var label: String { "\(Logger.isMain)✈️ RootView::" }
    var disk: Disk { dataManager.disk }

    var body: some View {
        Config.rootBackground

            // MARK: 版本升级操作

            .onAppear {
                Migrate().migrateTo25(dataManager: dataManager)
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
                        if dataManager.appScene == .Music {
                            BtnLike(asset: asset, autoResize: false)
                        }
                        
                        BtnShowInFinder(url: asset.url, autoResize: false)
                        
                        if dataManager.appScene == .Music {
                            BtnDel(assets: [asset], autoResize: false)
                        }
                    })
                }
            })
            .task {
                restore()

                playMan.onGetNextOf = { asset in
                    self.getNextOf(asset)
                }

                playMan.onGetPrevOf = { asset in
                    self.getPrevOf(asset)
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
                    os_log("\(self.label)执行后台任务")
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
    
    func getNextOf(_ asset: PlayAsset?) -> PlayAsset? {
        guard let asset = asset else {
            return nil
        }
        
        if dataManager.appScene != .Music {
            return DiskFile(url: asset.url).next()?.toPlayAsset()
        } else {
            return dbLocal.getNextOf(asset.url)?.toPlayAsset()
        }
    }

    // MARK: Prev
    
    func getPrevOf(_ asset: PlayAsset?) -> PlayAsset? {
        guard let asset = asset else {
            return nil
        }
        
        if dataManager.appScene != .Music {
            return DiskFile(url: asset.url).prev()?.toPlayAsset()
        } else {
            return dbLocal.getPrevOf(asset.url)?.toPlayAsset()
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
