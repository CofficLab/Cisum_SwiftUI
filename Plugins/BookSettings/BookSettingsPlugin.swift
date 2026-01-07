import MagicCore
import OSLog
import SwiftUI

/**
 * 有声书设置插件，提供仓库信息展示。
 *
 * 复用 `BookSettings` 视图，不重新创建仓库或监听。
 */
actor BookSettingsPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "⚙️"
    private static var enabled: Bool { false }
    private static let verbose = true

    let title = "有声书设置"
    let description = "有声书插件的设置入口"
    let iconName = "gearshape"
    let isGroup = false

    @MainActor
    func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)⚙️ 加载有声书设置视图")
        }
        return AnyView(BookSettings())
    }
}

// MARK: - PluginRegistrant

extension BookSettingsPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        // 紧随 BookPlugin 之后注册
        PluginRegistry.registerSync(order: 2) { Self() }
    }
}

