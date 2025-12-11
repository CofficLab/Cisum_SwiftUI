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

    let title = "有声书仓库"
    let description = "有声书数据库视图"
    let iconName = "books.vertical"
    let isGroup = false
    let verbose = true

    @MainActor
    func addDBView(reason: String, currentPluginId: String?) -> AnyView? {
        if verbose {
            os_log("\(self.t)📂 请求有声书数据库视图 reason=\(reason) currentId=\(currentPluginId ?? "nil")")
        }
        guard currentPluginId == nil || currentPluginId == Self.targetPluginId else { return nil }

        if verbose {
            os_log("\(self.t)✅ 返回 BookDBView")
        }
        return AnyView(BookDBView())
    }
}

// MARK: - PluginRegistrant

extension BookDBPlugin {
    @objc static func register() {
        // 紧随 BookPlugin 之后注册
        os_log("\(Self.t)注册 BookDBPlugin")
        PluginRegistry.registerSync(order: 2) { Self() }
    }
}

