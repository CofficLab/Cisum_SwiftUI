import MagicCore
import OSLog
import SwiftUI

/**
 * 有声书数据库插件：提供书籍仓库视图。
 *
 * 复用现有的 `BookDBView`，不重新创建仓库或监听。
 * 需要宿主注入同一个环境对象（BookRepo、AppProvider 等）。
 */
actor BookDBPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "📚📂"
    private nonisolated static let targetPluginId = String(describing: BookPlugin.self)
    private static let verbose = false

    let title = "有声书仓库"
    let description = "有声书数据库视图"
    let iconName = "books.vertical"
    let isGroup = false

    @MainActor
    func addDBView(reason: String, currentPluginId: String?) -> (view: AnyView, label: String)? {
        guard currentPluginId == nil || currentPluginId == Self.targetPluginId else { return nil }

        if BookDBPlugin.verbose {
            os_log("\(self.t)✅ 返回 BookDBView")
        }
        return (AnyView(BookDBView()), "有声书仓库")
    }
}

// MARK: - PluginRegistrant

extension BookDBPlugin {
    @objc static func register() {
        // 紧随 BookPlugin 之后注册
        if Self.verbose {
            os_log("\(self.t)🚀 注册 BookDBPlugin")
        }
        PluginRegistry.registerSync(order: 2) { Self() }
    }
}

