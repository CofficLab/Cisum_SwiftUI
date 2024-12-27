import AlertToast
import MagicKit
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    var content: Content
    static var emoji: String { "🌳" }
    let a = AppProvider()
    let s = StoreProvider()
    let c = ConfigProvider()

    @State var isDropping: Bool = false
    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    @StateObject var m = MessageProvider()
    @StateObject var p = PluginProvider()
    @StateObject var man: PlayMan = PlayMan(delegate: nil)

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if self.loading {
                ProgressView()
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
                                    if let asset = man.asset {
                                        BtnShowInFinder(url: asset.url, autoResize: false)
                                    }

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
                    .environmentObject(c)
                }
            }
        }
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
        #if os(iOS)
            .ignoresSafeArea()
        #endif
            .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
            .onChange(of: man.asset, onPlayAssetChange)
            .onChange(of: man.playing, onPlayingChange)
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

    func onCloudAccountStateChanged(_ n: Notification) {
        let newAvailability = FileManager.default.ubiquityIdentityToken != nil
        if newAvailability != iCloudAvailable {
            iCloudAvailable = newAvailability
        }
    }

    func onAppear() {
        man.delegate = self

        Task(priority: .userInitiated) {
            do {
                try Config.getPlugins().forEach({
                    try self.p.append($0, reason: self.className)
                })

                try? self.p.restoreCurrent()

                for plugin in p.plugins {
                    await plugin.onAppear(playMan: man, currentGroup: p.current)

                    plugin.onInit(storage: c.getStorageLocation())
                }

                #if os(iOS)
                    self.main.async {
                        UIApplication.shared.beginReceivingRemoteControlEvents()
                    }
                #endif
            } catch let e {
                self.error = e
            }

            self.loading = false
            os_log("\(self.t)👌👌👌 Ready")
        }
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
        os_log("\(self.t)🍋🍋🍋 Play Asset Change")

        Task {
            if let asset = man.asset, asset.isNotDownloaded {
                do {
                    try await asset.download()
                    os_log("\(self.t)onPlayAssetUpdate: 开始下载")
                } catch let e {
                    os_log(.error, "\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")
                }
            }
        }

        for plugin in p.plugins {
            Task {
                try await plugin.onPlayAssetUpdate(asset: man.asset, currentGroup: p.current)
            }
        }
    }

    func onPlayingChange() {
        Task {
            for plugin in p.plugins {
                if man.playing {
                    plugin.onPlay()
                } else {
                    await plugin.onPause(playMan: man)
                }
            }
        }
    }
}

// MARK: PlayManDelegate

extension RootView: PlayManDelegate {
    func onPlayPrev(current: PlayAsset?) {
        Task {
            for plugin in p.plugins {
                do {
                    try await plugin.onPlayPrev(playMan: man, current: current, currentGroup: p.current, verbose: true)
                } catch let e {
                    m.error(e)
                }
            }
        }
    }

    func onPlayNext(current: PlayAsset?, mode: PlayMode) async {
        for plugin in p.plugins {
            do {
                try await plugin.onPlayNext(playMan: man, current: current, currentGroup: p.current, verbose: true)
            } catch let e {
                m.alert(e.localizedDescription)
            }
        }
    }

    func onPlayModeChange(mode: PlayMode) {
        Task {
            for plugin in p.plugins {
                do {
                    try await plugin.onPlayModeChange(mode: mode, asset: man.asset)
                } catch let e {
                    m.error(e)
                }
            }
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
