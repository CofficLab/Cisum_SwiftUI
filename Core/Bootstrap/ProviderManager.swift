import MagicKit
import OSLog
import SwiftData
import SwiftUI

/// 服务提供者管理器
/// 负责集中管理应用程序的核心服务和提供者，确保服务只初始化一次
@MainActor
final class ProviderManager: SuperLog {
    static let shared = ProviderManager()
    static let verbose = false
    nonisolated static let emoji = "🔧"

    // Providers
    let app: AppProvider
    let stateMessageProvider: StateProvider
    let messageProvider: MagicMessageProvider
    let plugin: PluginProvider
    let cloud: CloudProvider

    // PlayMan
    let man: PlayMan

    private init() {
        // Repos
        let pluginRepo = PluginRepo()
        let uiRepo = UIRepo()

        // Providers
        self.app = AppProvider(uiRepo: uiRepo)
        self.stateMessageProvider = StateProvider()
        self.messageProvider = MagicMessageProvider.shared
        self.plugin = PluginProvider(repo: pluginRepo)
        self.cloud = CloudProvider()

        // PlayMan
        self.man = PlayMan(playlistEnabled: false, verbose: Self.verbose, locale: .current)

        if Self.verbose {
            os_log("\(Self.t)✅ 服务提供者初始化完成")
        }
    }
}
