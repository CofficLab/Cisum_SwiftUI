import Foundation
import MagicKit
import OSLog
import PluginReset
import SwiftUI

actor SystemPlugin: SuperPlugin, SuperLog {
    static let shared = SystemPlugin()
    static let emoji = ResetPluginInfo.emoji
    static let verbose = false
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 90，在其他插件之后执行
    static var order: Int { ResetPluginInfo.order }

    nonisolated var title: String { ResetPluginInfo.title }
    nonisolated var description: String { ResetPluginInfo.description }
    let iconName = ResetPluginInfo.iconName

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(
            SystemSetting(
                appVersion: MagicApp.getVersion(),
                resetSettings: {
                    await MainActor.run {
                        Config.resetStorageLocation()
                    }
                }
            )
        )
    }
}
