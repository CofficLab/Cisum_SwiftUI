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
                 ToolbarItem(placement: .navigation) {
                     BtnScene()
                 }

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
                onAppear()
            }
            .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onStateChanged)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManLike), perform: onToggleLike)
    }
}

// MARK: Event Handler

extension RootView {
    func onAppear() {
        let verbose = false
        
        playMan.onGetChildren = { asset in
            if let children = DiskFile(url: asset.url).children {
                return children.map({ $0.toPlayAsset() })
            }

            return []
        }

        #if os(iOS)
            self.main.async {
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
        #endif

        self.bg.async {
            if verbose {
                os_log("\(self.t)🐎🐎🐎 执行后台任务")
            }

            //            await self.onAppOpen()
        }

        //        Task {
        //            let uuid = Config.getDeviceId()
        //            let audioCount = disk.getTotal()
        //
        //            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        //        }
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

    func onToggleLike(_ notification: Notification) {
        if let asset = notification.userInfo?["asset"] as? PlayAsset {
            os_log("\(t)喜欢变了 -> \(asset.url.lastPathComponent)")
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
