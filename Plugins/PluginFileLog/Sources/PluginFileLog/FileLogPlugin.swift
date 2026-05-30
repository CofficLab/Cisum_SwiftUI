import CisumUI
import Foundation
import OSLog
#if os(macOS)
    import AppKit
#endif

public actor FileLogPlugin: SuperPlugin {
    public static let shared = FileLogPlugin()
    public static var order: Int { 1 }
    public static var shouldRegister: Bool { true }

    public nonisolated var title: String { FileLogPluginInfo.title }
    public nonisolated var description: String { FileLogPluginInfo.description }
    public nonisolated var iconName: String { FileLogPluginInfo.iconName }

    public nonisolated func onRegister() {
        FileLogCoordinator.shared.configuration = AppFileLogConfiguration()
        FileLogCoordinator.shared.start()

        #if os(macOS)
            NotificationCenter.default.addObserver(
                forName: NSApplication.willTerminateNotification,
                object: nil,
                queue: nil
            ) { _ in
                FileLogCoordinator.shared.stop()
            }
        #endif
    }
}

private struct AppFileLogConfiguration: FileLogConfiguration {
    func logsDirectory() -> URL {
        FileLogDirectory.defaultLogsDirectory()
    }
}
