import CisumUI
import OSLog
import PluginBook
import PluginBookScene
import SwiftUI

public actor BookDBPlugin: SuperPlugin {
    public static let shared = BookDBPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 12 }

    public nonisolated var title: String {
        String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), table: BookDBPluginInfo.table, bundle: .module)
    }

    public nonisolated var description: String {
        String(localized: String.LocalizationValue(BookDBPluginInfo.descriptionKey), table: BookDBPluginInfo.table, bundle: .module)
    }

    public nonisolated var iconName: String { BookDBPluginInfo.iconName }

    @MainActor
    public func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == BookScenePlugin.sceneName else { return nil }
        guard let dbRoot = try? BookPluginHost.getDBRootDir() else {
            os_log(.error, "BookDBPlugin failed to get database root")
            return nil
        }

        let dependencies = BookDBViewDependencies(
            dbRoot: dbRoot,
            bookDisk: BookPlugin.getBookDisk(),
            isDesktop: ConfigShim.isDesktop,
            isNotDesktop: ConfigShim.isNotDesktop
        )
        let view = BookDBView()
            .bookDBViewDependencies(dependencies)
        return (AnyView(view), String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), table: BookDBPluginInfo.table, bundle: .module))
    }
}

private enum ConfigShim {
    static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }

    static var isNotDesktop: Bool { !isDesktop }
}
