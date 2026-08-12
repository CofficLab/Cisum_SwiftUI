import CisumKernel
import CisumUI
import OSLog
import SwiftUI

public actor StoragePlugin: SuperPlugin, SuperLog, CisumKernelPlugin {
    public static let shared = StoragePlugin()
    public nonisolated static let emoji = "💾"
    public static let verbose = true
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(StoragePluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(StoragePluginInfo.descriptionKey), bundle: .module),
        iconName: StoragePluginInfo.iconName,
        order: 10
    )

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        let service = StorageService()
        StorageService.current = service
        kernel.registerStorage(service)
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)💾 加载存储设置视图")
        }

        let view = StorageSettingView()
            .pluginStorageDependencies(StorageService.makePluginDependencies())
        return AnyView(view)
    }
}
