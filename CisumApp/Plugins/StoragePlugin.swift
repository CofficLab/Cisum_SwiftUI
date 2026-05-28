import Foundation
import MagicKit
import OSLog
import PluginStorage
import SwiftUI

actor StoragePlugin: SuperPlugin, SuperLog {
    static let shared = StoragePlugin()
    nonisolated static let emoji = "💾"
    static let verbose = true
    static var shouldRegister: Bool { false }

    /// Registration order set to 10, execute after other plugins.
    static var order: Int { 10 }

    nonisolated var title: String { String(localized: String.LocalizationValue(StoragePluginInfo.titleKey), table: StoragePluginInfo.table) }
    nonisolated var description: String { String(localized: String.LocalizationValue(StoragePluginInfo.descriptionKey), table: StoragePluginInfo.table) }
    let iconName = StoragePluginInfo.iconName

    @MainActor
    func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)💾 加载存储设置视图")
        }

        let dependencies = StorageDependencies(
            getStorageLocation: {
                Config.getStorageLocation()?.pluginStorageLocation
            },
            updateStorageLocation: { location in
                Config.updateStorageLocation(location?.appStorageLocation)
            },
            getStorageRoot: {
                Config.getStorageRoot()
            },
            getStorageRootForLocation: { location in
                Config.getStorageRoot(for: location.appStorageLocation)
            },
            postStorageLocationUpdated: {
                NotificationCenter.postStorageLocationUpdated()
            },
            isDesktop: Config.isDesktop
        )

        let view = StorageSettingView()
            .pluginStorageDependencies(dependencies)
        return AnyView(view)
    }
}

private extension StorageLocation {
    var pluginStorageLocation: PluginStorageLocation {
        switch self {
        case .icloud: return .icloud
        case .local: return .local
        case .custom: return .custom
        }
    }
}

private extension PluginStorageLocation {
    var appStorageLocation: StorageLocation {
        switch self {
        case .icloud: return .icloud
        case .local: return .local
        case .custom: return .custom
        }
    }
}
