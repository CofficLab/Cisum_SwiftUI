import CisumUI
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
    @Environment(\.demoMode) var isDemoMode
    @State var iCloudAvailable = true

    @StateObject var appProvider: AppProvider
    @StateObject var pluginProvider: PluginProvider
    @StateObject var stateProvider: StateProvider
    @StateObject var themeProvider: AppThemeProvider

    var man: PlayMan
    var cloudProvider: CloudProvider

    /// 初始化 RootView
    /// - Parameters:
    ///   - providers: 可选的 Provider 管理器，如果为 nil 则创建新的实例
    ///   - content: 内容视图
    init(providers: ProviderManager? = nil, @ViewBuilder content: () -> Content) {
        // 如果提供了 providers，使用提供的；否则创建新的
        let manager = providers ?? ProviderManager()

        self.content = content()
        self._appProvider = StateObject(wrappedValue: manager.app)
        self._stateProvider = StateObject(wrappedValue: manager.stateMessageProvider)
        self._pluginProvider = StateObject(wrappedValue: manager.plugin)
        self._themeProvider = StateObject(wrappedValue: manager.theme)
        self.man = manager.man
        self.cloudProvider = manager.cloud
    }

    var body: some View {
        Group {
            if isDemoMode {
                content
            } else if self.launching {
                Guide()
            } else {
                if let e = self.error {
                    CrashedView(error: e)
                } else {
                    NavigationStack {
                        GeometryReader { proxy in
                            ZStack {
                            // iOS 的 NavigationStack 需要放这里才能设置背景
                                themeProvider.activeChromeTheme
                                    .makeGlobalBackground(proxy: proxy)
                                    .ignoresSafeArea()

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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .withMagicToast()
                }
            }
        }
        .background(themeProvider.activeChromeTheme.workspaceBackgroundColor())
        .preferredColorScheme(themeProvider.preferredColorScheme)
        .onStorageLocationChanged(perform: onStorageLocationChange)
        .onGuideDone(perform: onLaunchEnd)
        .onCloudAccountStateChanged(perform: onCloudAccountStateChanged)
        .onStorageLocationDidReset(perform: onResetStorageLocation)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .environmentObject(cloudProvider)
        .environmentObject(man)
        .environmentObject(appProvider)
        .environmentObject(pluginProvider)
        .environmentObject(stateProvider)
        .environmentObject(themeProvider)
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
    /// - Parameter providers: 可选的 Provider 管理器，如果为 nil 则创建新的实例
    /// - Returns: 被RootView包裹的视图
    func inRootView(providers: ProviderManager? = nil) -> some View {
        RootView(providers: providers) {
            self
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
