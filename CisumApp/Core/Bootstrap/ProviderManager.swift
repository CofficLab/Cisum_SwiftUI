import CisumUI
import MagicKit
import OSLog
import SwiftData
import SwiftUI

/// 服务提供者管理器
/// 负责创建和管理应用程序的核心服务和提供者
/// 不再是单例，每次调用 create() 都会创建新的实例
@MainActor
final class ProviderManager: SuperLog {
    static let verbose = false
    nonisolated static let emoji = "🔧"

    // Providers
    let app: AppProvider
    let stateMessageProvider: StateProvider
    let plugin: PluginProvider
    let theme: AppThemeProvider
    let cloud: CloudProvider

    // PlayMan
    let man: PlayMan

    /// 创建新的 ProviderManager 实例
    /// 每次调用都会创建新的 Provider 实例
    init() {
        // Repos
        let pluginRepo = PluginRepo()
        let uiRepo = UIRepo()

        // Providers
        self.app = AppProvider(uiRepo: uiRepo)
        self.stateMessageProvider = StateProvider()
        self.plugin = PluginProvider(repo: pluginRepo)
        self.theme = AppThemeProvider(pluginProvider: self.plugin)
        self.cloud = CloudProvider()

        // PlayMan
        self.man = PlayMan(
            verbose: Self.verbose,
            locale: .current,
            defaultArtwork: Image.cisumMusicFill,
            defaultArtworkBuilder: {
                LogoView()
            }
        )

        if Self.verbose {
            os_log("\(Self.t)✅ 服务提供者初始化完成")
        }
    }

    /// 共享单例，用于 App Intent 和其他需要全局访问的场景
    @MainActor
    static let shared = ProviderManager()
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
