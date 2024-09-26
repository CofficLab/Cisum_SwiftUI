import MagicKit
import OSLog
import SwiftUI

struct RootView: View, SuperLog, SuperEvent, SuperThread {
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
            .task(onAppearTask)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onStateChanged)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManModeChange), perform: onPlayModeChange)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManNext), perform: onGetNextOf)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManLike), perform: onToggleLike)
    }

    func onAppOpen() {
//        Task {
//            let uuid = Config.getDeviceId()
//            let audioCount = disk.getTotal()
//
//            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
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
}

// MARK: Event Handler

extension RootView {
    func onAppearTask() {
        playMan.onGetPrevOf = { asset in
            self.getPrevOf(asset)
        }

        playMan.onGetChildren = { asset in
            if let children = DiskFile(url: asset.url).children {
                return children.map({ $0.toPlayAsset() })
            }

            return []
        }

        #if os(iOS)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        #endif

        Task.detached(operation: {
            if verbose {
                os_log("\(self.t)🐎🐎🐎 执行后台任务")
            }

            await self.onAppOpen()
        })
    }

    func onStateChanged(_ notification: Notification) {
        let verbose = false

        if let state = notification.userInfo?["state"] as? PlayState {
            app.error = state.getError()
            self.bg.async {
                if verbose {
                    os_log("\(t)播放状态变了 -> \(state.des)")
                }
            }
        }
    }

    func onPlayModeChange(_ notification: Notification) {
        if let mode = notification.userInfo?["mode"] as? PlayMode {
            os_log("\(t)播放模式变了 -> \(mode.description)")
        }
    }

    func onToggleLike(_ notification: Notification) {
        if let asset = notification.userInfo?["asset"] as? PlayAsset {
            os_log("\(t)喜欢变了 -> \(asset.url.lastPathComponent)")
        }
    }

    func onGetNextOf(_ notification: Notification) {
        os_log("\(t)getNextOf")

//        if data.appScene != .Music {
        // return DiskFile(url: asset.url).nextDiskFile()?.toPlayAsset()
//        } else {
//
//        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
