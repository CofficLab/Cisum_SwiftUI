import MagicKit
import OSLog
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    nonisolated static var emoji: String { "🌳" }
    nonisolated static var verbose: Bool { true }

    var content: Content

    @State var error: Error? = nil

    /// 启动状态，表示LaunchViewSwitcher正在显示
    @State var launching = true
    @State var iCloudAvailable = true

    @StateObject var appProvider: AppProvider
    @StateObject var messageProvider: MagicMessageProvider
    @StateObject var pluginProvider: PluginProvider
    @StateObject var stateProvider: StateProvider

    var man: PlayMan
    var playManWrapper: PlayManWrapper
    var cloudProvider: CloudProvider
    var playManController: PlayManController

    init(@ViewBuilder content: () -> Content) {
        // 从 ProviderManager 获取共享的服务实例
        let manager = ProviderManager.shared

        self.content = content()
        self._appProvider = StateObject(wrappedValue: manager.app)
        self._messageProvider = StateObject(wrappedValue: manager.messageProvider)
        self._stateProvider = StateObject(wrappedValue: manager.stateMessageProvider)
        self._pluginProvider = StateObject(wrappedValue: manager.plugin)
        self.man = manager.man
        self.playManWrapper = manager.playManWrapper
        self.cloudProvider = manager.cloud
        self.playManController = manager.playManController
    }

    var body: some View {
        Group {
            if self.launching {
                Guide()
            } else {
                if let e = self.error {
                    CrashedView(error: e)
                } else {
                    NavigationStack {
                        ZStack {
                            Group {
                                if let wrapped = pluginProvider.wrapWithCurrentRoot(content: { content }) {
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
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .withMagicToast()
        .onStorageLocationChanged(perform: onStorageLocationChange)
        .onGuideDone(perform: onLaunchEnd)
        .onCloudAccountStateChanged(perform: onCloudAccountStateChanged)
        .onStorageLocationDidReset(perform: onResetStorageLocation)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Config.rootBackground)
        .environmentObject(cloudProvider)
        .environmentObject(man)
        .environmentObject(playManController)
        .environmentObject(self.appProvider)
        .environmentObject(pluginProvider)
        .environmentObject(messageProvider)
        .environmentObject(self.stateProvider)
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
                try self.pluginProvider.restoreCurrent()

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

    /// 隐藏TabView
    /// 通过修改AppProvider的showDB属性为false来隐藏TabView
    func hideTabView() -> some View {
        self.onAppear {
            ProviderManager.shared.app.closeDBView()
        }
    }
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 400, height: 700)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
