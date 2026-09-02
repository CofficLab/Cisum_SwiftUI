import CisumUIComponents
import OSLog
import PluginBook
import PluginBookScene
import SwiftUI

public actor BookDBPlugin: SuperPlugin {
    public static let shared = BookDBPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(BookDBPluginInfo.descriptionKey), bundle: .module),
        iconName: BookDBPluginInfo.iconName,
        order: 12
    )

    @MainActor
    public func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == BookScenePlugin.sceneName else { return nil }
        let label = String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module)
        let dbRoot: URL

        do {
            dbRoot = try BookPluginHost.getDBRootDir()
        } catch {
            os_log(.error, "BookDBPlugin failed to get database root: \(error.localizedDescription)")
            let view = BookDBUnavailableView(errorDescription: error.localizedDescription)
            return (AnyView(view), label)
        }

        let dependencies = BookDBViewDependencies(
            dbRoot: dbRoot,
            bookDisk: BookPlugin.getBookDisk(),
            isDesktop: ConfigShim.isDesktop,
            isNotDesktop: ConfigShim.isNotDesktop
        )
        let view = BookDBView()
            .bookDBViewDependencies(dependencies)
        return (AnyView(view), label)
    }
}

private struct BookDBUnavailableView: View {
    let errorDescription: String

    var body: some View {
        AppEmptyState(
            icon: "exclamationmark.triangle",
            title: String(localized: "Book repository is unavailable", bundle: .module),
            description: String(localized: "Database location could not be opened: \(errorDescription)", bundle: .module)
        )
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
