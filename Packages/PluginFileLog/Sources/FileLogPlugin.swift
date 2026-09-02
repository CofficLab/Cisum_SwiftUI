import CisumUI
import Foundation

public actor FileLogPlugin: SuperPlugin {
    public static let shared = FileLogPlugin()
    public static let metadata = PluginMetadata(
        displayName: FileLogPluginInfo.title,
        description: FileLogPluginInfo.description,
        iconName: FileLogPluginInfo.iconName,
        order: 1
    )

    public nonisolated func onRegister() {
        FileLogCoordinator.shared.configuration = AppFileLogConfiguration()
        FileLogCoordinator.shared.start()

        #if os(macOS)
            FileLogTerminationObserver.shared.start()
        #endif
    }

    public nonisolated func onDisable() {
        #if os(macOS)
            FileLogTerminationObserver.shared.stopObserving()
        #endif
        FileLogCoordinator.shared.stop()
    }
}
