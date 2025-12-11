import MagicCore
import OSLog
import SwiftUI

/**
 * 有声书海报插件，提供有声书封面视图。
 *
 * 复用 `BookPoster` 视图，不额外创建仓库或监听。
 */
actor BookPosterPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "📚🖼️"

    let title = "有声书"
    let description = "展示有声书海报"
    let iconName = "photo.on.rectangle"
    let isGroup = false
    let hasPoster = true
    let verbose = false

    @MainActor
    func addPosterView() -> AnyView? {
        if verbose {
            os_log("\(self.t)🖼️ 加载有声书海报视图")
        }

        return AnyView(BookPoster())
    }
}

// MARK: - PluginRegistrant

extension BookPosterPlugin {
    @objc static func register() {
        // 紧随 BookPlugin 之后注册
        PluginRegistry.registerSync(order: 2) { Self() }
    }
}

