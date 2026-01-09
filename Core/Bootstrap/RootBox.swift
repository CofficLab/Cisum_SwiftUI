import MagicKit
import OSLog
import SwiftData
import SwiftUI

/**
 * 核心服务管理器
 * 用于集中管理应用程序的核心服务和提供者，避免重复初始化
 * 配合 RootView 使用
 */
@MainActor
final class RootBox: SuperLog {
    static let shared = RootBox(reason: "Shared")
    static let verbose = false
    nonisolated static let emoji = "🚉"

    let app: AppProvider
    let stateMessageProvider: StateProvider
    let messageProvider: MagicMessageProvider
    let plugin: PluginProvider
    let man: PlayMan
    let playManWrapper: PlayManWrapper
    let playManController: PlayManController
    let cloud: CloudProvider

    private init(reason: String) {
        if Self.verbose {
            os_log("\(Self.onInit)(\(reason))")
        }
        
        // Repos
        let pluginRepo = PluginRepo()
        let uiRepo = UIRepo()

        // Providers
        self.app = AppProvider(uiRepo: uiRepo)
        self.stateMessageProvider = StateProvider()
        self.messageProvider = MagicMessageProvider.shared
        self.plugin = PluginProvider(autoDiscover: true, repo: pluginRepo)
        self.cloud = CloudProvider()

        self.man = PlayMan(playlistEnabled: false, verbose: false)
        self.playManWrapper = PlayManWrapper(playMan: self.man)
        self.playManController = PlayManController(playMan: self.man)
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
