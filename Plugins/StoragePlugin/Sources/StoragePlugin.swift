import CisumUI
import MagicKit
import OSLog
import SwiftUI

public actor StoragePlugin: SuperPlugin, SuperLog {
    public static let shared = StoragePlugin()
    public nonisolated static let emoji = "💾"
    public static let verbose = true
    public static let metadata = PluginMetadata(
        id: "StoragePlugin",
        displayName: String(localized: String.LocalizationValue(StoragePluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(StoragePluginInfo.descriptionKey), bundle: .module),
        iconName: StoragePluginInfo.iconName,
        order: 10
    )

    @MainActor
    public func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)💾 加载存储设置视图")
        }

        let view = StorageSettingView()
            .pluginStorageDependencies(StoragePluginHost.dependencies)
        return AnyView(view)
    }
}
