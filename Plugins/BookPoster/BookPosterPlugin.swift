import MagicKit
import OSLog
import SwiftUI

/**
 * 有声书海报插件，提供有声书封面视图。
 *
 * 复用 `BookPoster` 视图，不额外创建仓库或监听。
 */
actor BookPosterPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "🖼️"
    static let verbose = false

    let title = "有声书"
    let description = "适用于听有声书的场景"
    let iconName = "photo.on.rectangle"
    let isGroup = false

    @MainActor
    func addPosterView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)🖼️ 加载有声书海报视图")
        }

        return AnyView(BookPoster())
    }
}

// MARK: - PluginRegistrant

extension BookPosterPlugin {
    @objc static func register() {
        if Self.verbose {
            os_log("\(self.t)🚀 注册 BookPosterPlugin")
        }
        PluginRegistry.registerSync(order: 2) { Self() }
    }
}

