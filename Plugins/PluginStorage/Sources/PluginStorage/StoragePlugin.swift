import CisumUI
import MagicKit
import OSLog
import SwiftUI

public actor StoragePlugin: SuperPlugin, SuperLog {
    public static let shared = StoragePlugin()
    public nonisolated static let emoji = "💾"
    public static let verbose = true
    public static var shouldRegister: Bool { false }
    public static var order: Int { 10 }

    public nonisolated var title: String { String(localized: String.LocalizationValue(StoragePluginInfo.titleKey), table: StoragePluginInfo.table) }
    public nonisolated var description: String { String(localized: String.LocalizationValue(StoragePluginInfo.descriptionKey), table: StoragePluginInfo.table) }
    public let iconName = StoragePluginInfo.iconName

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
