import MagicKit
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    nonisolated static var emoji: String { "🌳" }
    nonisolated static var verbose: Bool { false }

    var content: Content

    @State var error: Error? = nil

    /// 启动状态，表示LaunchViewSwitcher正在显示
    @State var launching = true
    @State var iCloudAvailable = true

    @StateObject var a: AppProvider
    @StateObject var m: MagicMessageProvider
    @StateObject var p: PluginProvider
    @StateObject var stateProvider: StateProvider

    var man: PlayMan
    var playManWrapper: PlayManWrapper
    var cloudProvider: CloudProvider
    var playManController: PlayManController

    init(@ViewBuilder content: () -> Content) {
        if Self.verbose {
            os_log("\(Self.t)🚀 初始化开始")
        }

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
        Group {
            if self.launching {
                Launcher(plugins: p.plugins)
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
                    .onStorageLocationDidReset(perform: onResetStorageLocation)
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
        .onLaunchDone(perform: onLaunchEnd)
    }

    private func reloadView() {
        launching = true
        error = nil
    }
}

// MARK: - Actions

extension RootView {
    func boot() {
        if Self.verbose {
            os_log("\(self.t)🚀 Boot")
        }
        Task {
            do {
                try self.p.restoreCurrent()

                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif
            } catch let e {
                self.error = e
            }
        }
    }
}

// MARK: - Setters

extension RootView {
    func setError(_ e: Error) {
        self.error = e
    }

    func setLoading(_ l: Bool, reason: String) {
        if Self.verbose {
            os_log("\(self.t)👷 设置加载状态: \(l), reason: \(reason)")
        }
        self.launching = l
    }
}

// MARK: Event Handler

extension RootView {
    func onResetStorageLocation() {
        if Self.verbose {
            os_log("\(self.t)🔄 Reset Storage Location")
        }
        setLoading(true, reason: "resetStorageLocation")
    }

    func onLaunchEnd() {
        if Self.verbose {
            os_log("\(self.t)✅ Launch Done")
        }

        setLoading(false, reason: "launchEnd")
        boot()
    }

    func onChangeOfiCloud() {
        if iCloudAvailable {
            reloadView()
        }
    }

    func onStorageLocationChange() {
        if Config.getStorageLocation() == nil {
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
