import MagicCore
import OSLog
import SwiftUI

/**
 * 音频数据库插件：提供音频仓库列表视图。
 */
actor AudioDBPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "🎵"
    private nonisolated static let targetPluginId = String(describing: AudioPlugin.self)
    private static let verbose = true
    private static var enabled: Bool { false }

    let title = "音频仓库"
    let description = "音频文件数据库视图"
    let iconName = "externaldrive"
    let isGroup = false

    @MainActor
    func addTabView(reason: String, currentPluginId: String?) -> (view: AnyView, label: String)? {
        guard currentPluginId == nil || currentPluginId == Self.targetPluginId else { return nil }

        if Self.verbose {
            os_log("\(self.t)✅ 返回 AudioDBView")
        }
        return (AnyView(AudioDBView()), "音乐仓库")
    }
}

// MARK: - PluginRegistrant

extension AudioDBPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        // 紧随 AudioPlugin 之后注册
        if Self.verbose {
            os_log("\(self.t)🚀 注册 AudioDBPlugin")
        }
        PluginRegistry.registerSync(order: 1) { Self() }
    }
}

