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
    @State var currentLaunchPageIndex: Int = 0

    @StateObject var a: AppProvider
    @StateObject var m: MagicMessageProvider
    @StateObject var p: PluginProvider
    @StateObject var stateProvider: StateProvider

    var man: PlayMan
    var playManWrapper: PlayManWrapper
    var s: StoreProvider
    var cloudProvider: CloudProvider
    var playManController: PlayManController
    private var verbose = false

    init(@ViewBuilder content: () -> Content) {
        os_log("\(Self.onInit)")

        let box = RootBox.shared
        self.content = content()
        self._a = StateObject(wrappedValue: box.app)
        self._m = StateObject(wrappedValue: box.messageProvider)
        self._stateProvider = StateObject(wrappedValue: box.stateMessageProvider)
        self._p = StateObject(wrappedValue: box.plugin)
        self.man = box.man
        self.playManWrapper = box.playManWrapper
        self.s = box.store
        self.cloudProvider = box.cloud
        self.playManController = box.playManController
    }

    var body: some View {
        os_log("\(self.t)开始渲染")
        return Group {
            if self.loading {
                LaunchViewSwitcher(
                    currentLaunchPageIndex: $currentLaunchPageIndex,
                    plugins: p.plugins,
                    onAppear: onAppear
                )
            } else {
                if let e = self.error {
                    ErrorViewFatal(error: e)
                } else {
                    NavigationStack {
                        ZStack {
                            content
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
                                .toolbar {
                                    RootToolbar()
                                }
                                .blendMode(.normal)
                                .background(Config.rootBackground)

                            ForEach(Array(p.getRootViews().enumerated()), id: \.offset) { _, view in
                                view
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(man)
                    .environmentObject(playManController)
                    .environmentObject(self.a)
                    .environmentObject(s)
                    .environmentObject(p)
                    .environmentObject(m)
                    .environmentObject(self.stateProvider)
                    .sheet(isPresented: self.$a.showSheet, content: {
                        VStack {
                            ForEach(Array(p.getSheetViews(storage: Config.getStorageLocation()).enumerated()), id: \.offset) { _, view in
                                view
                            }
                        }
                        .environmentObject(man)
                        .environmentObject(playManController)
                        .environmentObject(self.a)
                        .environmentObject(s)
                        .environmentObject(p)
                        .environmentObject(m)
                    })
                }
            }
        }
        .environmentObject(cloudProvider)
        .withMagicToast()
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Config.rootBackground)
        .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
        .onChange(of: Config.getStorageLocation(), onStorageLocationChange)
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
        if Config.getStorageLocation() == nil {
            a.showSheet = true
            return
        }

        Task {
            do {
                try await p.handleStorageLocationChange(storage: Config.getStorageLocation())
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
                try await p.handleOnAppear(playMan: playManWrapper, current: p.current, storage: Config.getStorageLocation())

                a.showSheet = p.getSheetViews(storage: Config.getStorageLocation()).isNotEmpty

                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif

                self.man.subscribe(
                    name: self.className,
                    onStateChanged: { state in
                        if verbose {
                            os_log("\(self.t)🐯 播放状态变为 -> \(state.stateText)")
                        }
                        if state == .paused {
                            Task {
                                do {
                                    try await self.p.onPause(man: playManWrapper)
                                } catch {
                                    m.error(error)
                                }
                            }
                        }

                        if state.isUnsupportedFormat {
                            m.info("不支持的格式，自动播放下一首")
                            Task {
                                // 不支持的格式，1秒后自动播放下一首
                                try await Task.sleep(nanoseconds: 1000000000) // 1秒延迟
                                do {
                                    try await self.p.onPlayNext(current: man.currentAsset, mode: man.playMode, man: playManWrapper)
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

extension View {
    /// 将当前视图包裹在RootView中
    /// - Returns: 被RootView包裹的视图
    func inRootView() -> some View {
        RootView {
            self
        }
    }
}

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
