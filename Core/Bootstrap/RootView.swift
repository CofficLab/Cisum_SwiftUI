import AlertToast
import MagicKit
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    var content: Content
    let emoji = "🌳"
    let a = AppProvider()
    let s = StoreProvider()
    let db = DB(Config.getContainer, reason: "BootView")
    let dbSyncedd = DBSynced(Config.getSyncedContainer)

    @State var dataManager: DataProvider?
    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    @StateObject var m = MessageProvider()
    @StateObject var p = PluginProvider()
    @StateObject var man = PlayMan()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if self.loading {
                ProgressView()
            } else {
                Group {
                    if let e = self.error {
                        if e.isCloudError {
                            ErrorViewCloud(error: e)
                                .onChange(of: iCloudAvailable, onChangeOfiCloud)
                        } else {
                            ErrorViewFatal(error: e)
                        }
                    } else {
                        if let dataManager = dataManager {
                            content
                                .toolbar(content: {
                                    ToolbarItem(placement: .navigation) {
                                        BtnScene()
                                    }

                                    ToolbarItemGroup(placement: .cancellationAction) {
                                        Spacer()
                                        ForEach(p.getToolBarButtons(), id: \.id) { item in
                                            item.view
                                        }
                                    }
                                })
                                .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
                                .blendMode(.normal)
                                .environmentObject(man)
                                .environmentObject(a)
                                .environmentObject(s)
                                .environmentObject(p)
                                .environmentObject(dataManager)
                                .environmentObject(db)
                                .environmentObject(dbSyncedd)
                                .environmentObject(m)
                        } else {
                            Text("启动失败")
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $m.showToast, alert: {
            AlertToast(type: .systemImage("info.circle", .blue), title: m.toast)
        }, completion: {
            m.clearToast()
        })
        .toast(isPresenting: $m.showAlert, alert: {
            AlertToast(displayMode: .alert, type: .error(.red), title: m.alert)
        }, completion: {
            m.clearAlert()
        })
        .toast(isPresenting: $m.showDone, alert: {
            AlertToast(type: .complete(.green), title: m.doneMessage)
        }, completion: {
            m.clearDoneMessage()
        })
        .toast(isPresenting: $m.showError, duration: 0, tapToDismiss: true, alert: {
            AlertToast(displayMode: .alert, type: .error(.indigo), title: m.error?.localizedDescription)
        }, completion: {
            m.clearError()
        })
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(
            Config.rootBackground)
        .ignoresSafeArea()
        .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .onChange(of: man.asset, onPlayAssetChange)
    }

    private func reloadView() {
        loading = true
        error = nil
        dataManager = nil
    }
}

// MARK: Event Handler

extension RootView {
    func onChangeOfiCloud() {
        if iCloudAvailable {
            reloadView()
        }
    }

    func onCloudAccountStateChanged(_ n: Notification) {
        let newAvailability = FileManager.default.ubiquityIdentityToken != nil
        if newAvailability != iCloudAvailable {
            iCloudAvailable = newAvailability
        }
    }

    func onAppear() {
        Task {
            do {
                try dataManager = await DataProvider(verbose: true)
            } catch let e {
                self.error = e
            }

            self.loading = false
        }

        self.p.append(AudioPlugin())
        self.p.append(DebugPlugin())
        self.p.append(BookPlugin())
        
        try? self.p.setCurrentGroup(p.plugins.first!)

        p.plugins.forEach({
            $0.onAppear(playMan: man, currentGroup: p.current)
        })

        let verbose = false

//        play.onGetChildren = { asset in
//            if let children = DiskFile(url: asset.url).children {
//                return children.map({ $0.toPlayAsset() })
//            }
//
//            return []
//        }

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

    func onDisappear() {
        p.plugins.forEach({
            $0.onDisappear()
        })
    }

    func onPlayManStateChange() {
        p.plugins.forEach({
            $0.onPlayStateUpdate()
        })
    }

    func onPlayAssetChange() {
        p.plugins.forEach({
            $0.onPlayAssetUpdate(asset: man.asset)
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
