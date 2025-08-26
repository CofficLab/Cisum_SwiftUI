import MagicCore
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    nonisolated static var emoji: String { "🌳" }

    var content: Content

    @State var isDropping: Bool = false
    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    @StateObject var a: AppProvider
    @StateObject var m: MagicMessageProvider
    @StateObject var p: PluginProvider
    @StateObject var stateProvider: StateProvider

    var man: PlayMan
    var playManWrapper: PlayManWrapper
    var c: ConfigProvider
    var s: StoreProvider
    var cloudProvider: CloudProvider

    init(@ViewBuilder content: () -> Content) {
        os_log("\(Self.onInit)")

        let box = RootBox.shared
        self.content = content()
        self._a = StateObject(wrappedValue: box.app)
        self._m = StateObject(wrappedValue: box.messageProvider)
        self._stateProvider = StateObject(wrappedValue: box.stateMessageProvider)
        self._p = StateObject(wrappedValue: box.plugin)
        self.c = box.config
        self.man = box.man
        self.playManWrapper = box.playManWrapper
        self.s = box.store
        self.cloudProvider = box.cloud
    }

    var body: some View {
        Group {
            if self.loading {
                LaunchView()
            } else if self.a.isResetting {
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

                                    man.currentURL?
                                        .makeOpenButton()
                                        .magicShapeVisibility(.onHover)
                                        .magicSize(.small)

                                    man.makeLogButton()
                                        .magicShape(.circle)
                                        .magicShapeVisibility(.onHover)
                                        .magicSize(.small)
                                    // .onlyDebug()
                                    man.makeLikeButton()
                                        .magicShape(.circle)
                                        .magicShapeVisibility(.onHover)
                                        .magicSize(.small)

                                    MagicLogger
                                        .logButton()
                                        .magicSize(.small)
                                        .magicShapeVisibility(.onHover)
                                    // .onlyDebug()

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
                    .environmentObject(self.a)
                    .environmentObject(s)
                    .environmentObject(p)
                    .environmentObject(m)
                    .environmentObject(self.stateProvider)
                    .sheet(isPresented: self.$a.showSheet, content: {
                        VStack {
                            ForEach(Array(p.getSheetViews(storage: c.storageLocation).enumerated()), id: \.offset) { _, view in
                                view
                            }
                        }
                        .environmentObject(man)
                        .environmentObject(self.a)
                        .environmentObject(s)
                        .environmentObject(p)
                        .environmentObject(m)
                    })
                }
            }
        }
        .environmentObject(c)
        .environmentObject(cloudProvider)
        .withMagicToast()
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Config.rootBackground)
        .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
        .onAppear(perform: onAppear)
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
        if c.storageLocation == nil {
            a.showSheet = true
            return
        }

        Task {
            do {
                try await p.handleStorageLocationChange(storage: c.storageLocation)
            } catch {
                m.error(error)
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
        Task {
            do {
                try self.p.restoreCurrent()
                try await p.handleOnAppear(playMan: playManWrapper, current: p.current, storage: c.getStorageLocation())

                a.showSheet = p.getSheetViews(storage: c.storageLocation).isNotEmpty

                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif

                os_log("\(self.t)👀 订阅 PlayMan 状态")
                self.man.subscribe(
                    name: self.className,
                    onStateChanged: { state in
                        os_log("\(self.t)🐯 播放状态变为 -> \(state.stateText)")
                        if state == .paused {
                            Task {
                                do {
                                    try await self.p.onPause(man: playManWrapper)
                                } catch {
                                    m.error(error)
                                }
                            }
                        }
                    },
                    onPreviousRequested: { asset in
                        os_log("\(self.t)⏮️ 上一首")
                        Task {
                            do {
                                try await self.p.onPlayPrev(current: asset, mode: man.playMode, man: playManWrapper)
                            } catch {
                                m.error(error)
                            }
                        }
                    },
                    onNextRequested: { asset in
                        m.info("下一首")
                        Task {
                            do {
                                try await self.p.onPlayNext(current: asset, mode: man.playMode, man: playManWrapper)
                            } catch {
                                m.error(error)
                            }
                        }
                    },
                    onLikeStatusChanged: { asset, like in
                        os_log("\(self.t)❤️ 喜欢状态 -> \(like)")
                        Task {
                            do {
                                try await self.p.onLike(asset: asset, liked: like)
                            } catch {
                                m.error(error)
                            }
                        }
                    },
                    onPlayModeChanged: { mode in
                        m.info("播放模式 -> \(mode.shortName)")
                        Task {
                            do {
                                try await self.p.onPlayModeChange(mode: mode, asset: man.currentAsset)
                            } catch {
                                self.m.error(error)
                            }
                        }
                    },
                    onCurrentURLChanged: { url in
                        m.info(url.title)
                        Task {
                            do {
                                try await self.p.onCurrentURLChanged(url: url)
                            } catch {
                                m.error(error)
                            }
                        }
                    }
                )
            } catch let e {
                self.error = e
            }

            self.loading = false
        }
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
