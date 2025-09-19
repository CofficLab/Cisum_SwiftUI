import MagicCore
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    nonisolated static var emoji: String { "🌳" }

    var content: Content

    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    @StateObject var a: AppProvider
    @StateObject var m: MagicMessageProvider
    @StateObject var p: PluginProvider
    @StateObject var stateProvider: StateProvider

    var man: PlayMan
    var playManWrapper: PlayManWrapper
    var cloudProvider: CloudProvider
    var playManController: PlayManController
    private var verbose = true

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
        self.cloudProvider = box.cloud
        self.playManController = box.playManController
    }

    var body: some View {
        if self.verbose {
            os_log("\(self.t)👷 开始渲染, isLoading: \(self.loading)")
        }
        return Group {
            if self.loading {
                LaunchViewSwitcher(
                    plugins: p.plugins,
                    onEnd: boot
                )
            } else {
                if let e = self.error {
                    ErrorViewFatal(error: e)
                } else {
                    NavigationStack {
                        ZStack {
                            Group {
                                if let wrapped = p.wrapWithCurrentRoot(content: { content }) {
                                    wrapped
                                } else {
                                    content
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
                            .toolbar {
                                RootToolbar()
                            }
                            .blendMode(.normal)
                            .background(Config.rootBackground)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(man)
                    .environmentObject(playManController)
                    .environmentObject(self.a)
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

// MARK: - Actions

extension RootView {
    func boot() {
        if verbose {
            os_log("\(self.t)🚀 Boot")
        }
        Task {
            do {
                try self.p.restoreCurrent()

                a.showSheet = p.getSheetViews(storage: Config.getStorageLocation()).isNotEmpty

                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif
            } catch let e {
                self.error = e
            }

            self.loading = false
        }
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
    }

    func onCloudAccountStateChanged(_ n: Notification) {
        let newAvailability = FileManager.default.ubiquityIdentityToken != nil
        if newAvailability != iCloudAvailable {
            iCloudAvailable = newAvailability
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
