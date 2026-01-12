import MagicKit
import OSLog
import SwiftUI

/**
 * 音频设置插件，提供音频设置面板。
 */
actor AudioSettingsPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "🛠️"
    private static var enabled: Bool { true }
    private static let verbose = false

    let title = "音频设置"
    let description = "音频插件的设置入口"
    let iconName = "gearshape"
    let isGroup = false

    @MainActor
    func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)⚙️ 加载音频设置视图")
        }

        return AnyView(AudioSettings())
    }
}

// MARK: - PluginRegistrant

extension AudioSettingsPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        if Self.verbose {
            os_log("\(self.t)🚀 Register")
        }

        // 放在主 AudioPlugin 之后注册即可
        PluginRegistry.registerSync(order: 1) { Self() }
    }
}

