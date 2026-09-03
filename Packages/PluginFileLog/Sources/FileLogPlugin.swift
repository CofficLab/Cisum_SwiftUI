import CisumUIComponents
import KernelCore
import Foundation

public actor FileLogPlugin: SuperPlugin {
    public static let shared = FileLogPlugin()
    public static let metadata = PluginMetadata(
        displayName: FileLogPluginInfo.title,
        description: FileLogPluginInfo.description,
        iconName: FileLogPluginInfo.iconName,
        order: 1
    )

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        FileLogCoordinator.shared.configuration = AppFileLogConfiguration()
        FileLogCoordinator.shared.start()

        #if os(macOS)
            FileLogTerminationObserver.shared.start()
        #endif
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        #if os(macOS)
            FileLogTerminationObserver.shared.stopObserving()
        #endif
        FileLogCoordinator.shared.stop()
    }
}
