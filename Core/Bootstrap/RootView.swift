import AlertToast
import MagicKit
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    var content: Content
    let emoji = "🌳"
    let a = AppProvider()
    let s = StoreProvider()

    @State var dataManager: DataProvider?
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
                    if e.isCloudError {
                        ErrorViewCloud(error: e)
                            .onChange(of: iCloudAvailable, onChangeOfiCloud)
                    } else {
                        ErrorViewFatal(error: e)
                    }
                } else {
                    if let dataManager = dataManager {
                        ZStack {
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
                                .environmentObject(m)
                        }
                    } else {
                        Text("启动失败")
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
        .background(Config.rootBackground)
//        .ignoresSafeArea()
        .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .onChange(of: man.asset, onPlayAssetChange)
        .onChange(of: man.playing, onPlayingChange)
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
        man.delegate = self

        Task {
            do {
                try dataManager = await DataProvider(verbose: true)

                Config.getPlugins().forEach({
                    self.p.append($0)
                })

                self.p.restoreCurrent()

                for plugin in p.plugins {
                    plugin.onAppear(playMan: man, currentGroup: p.current)
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
        for plugin in p.plugins {
            Task {
                try await plugin.onPlayAssetUpdate(asset: man.asset, currentGroup: p.current)
            }
        }
    }

    func onPlayingChange() {
        p.plugins.forEach({
            if man.playing {
                $0.onPlay()
            } else {
                $0.onPause(playMan: man)
            }
        })
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
        for plugin in p.plugins {
            plugin.onPlayModeChange(mode: mode)
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
