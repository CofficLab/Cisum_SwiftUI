import CisumUI
import MagicKit
import OSLog
import PluginAudio
import PluginAudioProgress
import PluginBook
import PluginStorage
import PluginWelcome
import SwiftUI

struct RootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    nonisolated static var emoji: String { "🌳" }
    nonisolated static var verbose: Bool { false }

    static func shouldEndLaunchAfterStorageLocationChange(isLaunching: Bool, hasUsableStorageLocation: Bool) -> Bool {
        isLaunching && hasUsableStorageLocation
    }

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
            } else if let e = self.error ?? pluginProvider.initializationError {
                CrashedView(error: e)
            } else if self.launching {
                Guide()
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
        .environment(\.resetSettingsAction, {
            await MainActor.run {
                Config.resetStorageLocation()
            }
        })
        .environment(\.pluginThemes, themeProvider.themes)
        .environment(\.currentPluginThemeId, themeProvider.currentThemeId)
        .environment(\.selectPluginThemeAction, { themeId in
            themeProvider.selectTheme(themeId)
        })
        .environment(\.currentSceneName, pluginProvider.currentSceneName)
        .environment(
            \.appIsImporting,
            Binding(
                get: { appProvider.isImporting },
                set: { appProvider.isImporting = $0 }
            )
        )
        .environment(\.showAudioDBViewAction, {
            appProvider.showDBView()
        })
        .onAppear {
            AudioPluginHost.configure(
                databaseURL: { try Config.createDatabaseFile(name: $0) },
                storageRoot: { Config.getStorageRoot() },
                hasStorageLocation: { Config.hasUsableStorageLocation() },
                storageLocationDidChangeNotifications: [
                    .storageLocationDidReset,
                    .storageLocationUpdated
                ]
            )
            AudioProgressHost.configure(saveWidgetData: { title, artist, isPlaying, coverArt in
                WidgetData.save(title: title, artist: artist, isPlaying: isPlaying, coverArt: coverArt)
            })
            BookPluginHost.configure(
                dbRoot: { try Config.getDBRootDir() },
                storageRoot: { Config.getStorageRoot() },
                storageLocationDidChangeNotifications: [
                    .storageLocationDidReset,
                    .storageLocationUpdated
                ]
            )
            StoragePluginHost.configure(
                getStorageLocation: {
                    Config.getStorageLocation()?.pluginStorageLocation
                },
                updateStorageLocation: { location in
                    Config.updateStorageLocation(location?.appStorageLocation)
                },
                getStorageRoot: {
                    Config.getStorageRoot()
                },
                getStorageRootForLocation: { location in
                    Config.getStorageRoot(for: location.appStorageLocation)
                },
                postStorageLocationUpdated: {
                    NotificationCenter.postStorageLocationUpdated()
                },
                isDesktop: Config.isDesktop
            )
        }
    }

    private func reloadView() {
        launching = true
        error = nil
    }
}

private extension StorageLocation {
    var pluginStorageLocation: PluginStorageLocation {
        switch self {
        case .icloud:
            return .icloud
        case .local:
            return .local
        case .custom:
            return .custom
        }
    }
}

private extension PluginStorageLocation {
    var appStorageLocation: StorageLocation {
        switch self {
        case .icloud:
            return .icloud
        case .local:
            return .local
        case .custom:
            return .custom
        }
    }
}

// MARK: - Actions

extension RootView {
    func boot() {
        if Self.verbose {
            os_log("\(self.t)🚀 Boot")
        }
        Task { @MainActor in
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
        guard launching else { return }

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
        guard Self.shouldEndLaunchAfterStorageLocationChange(
            isLaunching: launching,
            hasUsableStorageLocation: Config.hasUsableStorageLocation()
        ) else {
            return
        }

        onLaunchEnd()
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
