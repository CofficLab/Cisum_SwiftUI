import AlertToast
import MagicPlayMan
import MagicKit
import MagicUI
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, @preconcurrency SuperLog, SuperThread where Content: View {
    var content: Content
    static var emoji: String { "🌳" }
    let s = StoreProvider()
    let cloudProvider = CloudProvider()

    @State var isDropping: Bool = false
    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    @StateObject var m = MessageProvider()
    @StateObject var p = PluginProvider()
    @StateObject var a = AppProvider()
    @StateObject var man = MagicPlayMan(playlistEnabled: false)
    @StateObject var c = ConfigProvider()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if self.loading {
                ProgressView()
            } else if a.isResetting {
                Text("正在重置")
            } else {
                if let e = self.error {
                    ErrorViewFatal(error: e)
                } else {
                    ZStack {
                        content
                            .toolbar(content: {
                                if p.groupPlugins.count > 1 {
                                    ToolbarItem(placement: .navigation) {
                                        BtnScene()
                                    }
                                }

                                ToolbarItemGroup(placement: .cancellationAction) {
                                    Spacer()
                                    
                                    man.makeLogButton(shape: .roundedRectangle)
                                    man.makeLikeButton()

                                    if man.asset != nil {
                                        ForEach(p.getToolBarButtons(), id: \.id) { item in
                                            item.view
                                        }
                                    }
                                }
                            })
                            .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
                            .blendMode(.normal)

                        ForEach(Array(p.getRootViews().enumerated()), id: \.offset) { _, view in
                            view
                        }
                    }
                    .environmentObject(man)
                    .environmentObject(a)
                    .environmentObject(s)
                    .environmentObject(p)
                    .environmentObject(m)
                    .sheet(isPresented: $a.showSheet, content: {
                        VStack {
                            ForEach(Array(p.getSheetViews(storage: c.storageLocation).enumerated()), id: \.offset) { _, view in
                                view
                            }
                        }
                        .environmentObject(man)
                        .environmentObject(a)
                        .environmentObject(s)
                        .environmentObject(p)
                        .environmentObject(m)
                    })
                }
            }
        }
        .environmentObject(c)
        .environmentObject(cloudProvider)
        .toast(isPresenting: $m.showHub, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: m.hub)
        })
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
        .background(Config.rootBackground)
        .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .onChange(of: man.asset, onPlayAssetChange)
        .onChange(of: man.playing, onPlayingChange)
        .onChange(of: c.storageLocation, onStorageLocationChange)
    }

    private func reloadView() {
        loading = true
        error = nil
    }
}

// MARK: Event Handler

extension RootView {
    func onChangeOfiCloud() {
        if iCloudAvailable {
            reloadView()
        }
    }

    func onStorageLocationChange() {
        os_log("\(self.t)🍋🍋🍋 Storage Location Change")

        if c.storageLocation == nil {
            a.showSheet = true

            return
        }

        for plugin in p.plugins {
            Task {
                try await plugin.onStorageLocationChange(storage: c.storageLocation)
            }
        }
    }

    func onCloudAccountStateChanged(_ n: Notification) {
        let newAvailability = FileManager.default.ubiquityIdentityToken != nil
        if newAvailability != iCloudAvailable {
            iCloudAvailable = newAvailability
        }
    }

    func onAppear() {
//        Task(priority: .userInitiated) {
//            do {
//                try Config.getPlugins().forEach({
//                    try self.p.append($0, reason: self.className)
//                })
//
//                try? self.p.restoreCurrent()
//
//                for plugin in p.plugins {
//                    try await plugin.onWillAppear(playMan: man, currentGroup: p.current, storage: c.getStorageLocation())
//                }
//
//                a.showSheet = p.getSheetViews(storage: c.storageLocation).isNotEmpty
//
//                #if os(iOS)
//                    self.main.async {
//                        UIApplication.shared.beginReceivingRemoteControlEvents()
//                    }
//                #endif
//                
//                self.man.subscribe(
//                    name: self.className,
//                    onPreviousRequested: { asset in
//                        self.onPlayPrev(current: asset)
//                    },
//                    onNextRequested: { asset in
//                        self.onPlayNext(current: asset, mode: self.man.playMode)
//                    }
//                )
//            } catch let e {
//                self.error = e
//            }
//
//            self.loading = false
//            os_log("\(self.t)👌👌👌 Ready")
//        }
    }

    func onDisappear() {
        p.plugins.forEach({
            $0.onDisappear()
        })
    }

    func onPlayManStateChange() {
        for plugin in p.plugins {
            Task {
                try await plugin.onPlayStateUpdate()
            }
        }
    }

    func onPlayAssetChange() {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)🍋🍋🍋 Play Asset Change")
        }

//        Task {
//            if let asset = man.asset, asset.isNotDownloaded {
//                do {
//                    try await asset.download()
//                    os_log("\(self.t)onPlayAssetUpdate: 开始下载")
//                } catch let e {
//                    os_log(.error, "\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")
//                }
//            }
//        }

//        for plugin in p.plugins {
//            Task {
//                try await plugin.onPlayAssetUpdate(asset: man.asset, currentGroup: p.current)
//            }
//        }
    }

    func onPlayingChange() {
//        Task {
//            for plugin in p.plugins {
//                if man.playing {
//                    plugin.onPlay()
//                } else {
//                    await plugin.onPause(playMan: man)
//                }
//            }
//        }
    }
}

// MARK: PlayMan Event

extension RootView {
    func onPlayPrev(current: MagicAsset?) {
//        Task {
//            for plugin in p.plugins {
//                do {
//                    try await plugin.onPlayPrev(playMan: man, current: current, currentGroup: p.current, verbose: true)
//                } catch let e {
//                    m.error(e)
//                }
//            }
//        }
    }

    func onPlayNext(current: MagicAsset?, mode: PlayMode) {
//        Task {
//            for plugin in p.plugins {
//                do {
//                    try await plugin.onPlayNext(playMan: man, current: current, currentGroup: p.current, verbose: true)
//                } catch let e {
//                    m.alert(e.localizedDescription)
//                }
//            }
//        }
    }

    func onPlayModeChange(mode: PlayMode) {
//        Task {
//            for plugin in p.plugins {
//                do {
//                    try await plugin.onPlayModeChange(mode: mode, asset: man.asset)
//                } catch let e {
//                    m.error(e)
//                }
//            }
//        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
