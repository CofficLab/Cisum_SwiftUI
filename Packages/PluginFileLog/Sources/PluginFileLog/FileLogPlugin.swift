import CisumUI
import AppKit
import Foundation
import OSLog

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

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: nil
        ) { _ in
            FileLogCoordinator.shared.stop()
        }
    }
}

private struct AppFileLogConfiguration: FileLogConfiguration {
    func logsDirectory() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "com.yueyi.cisum"
        #if DEBUG
            let env = "db_debug"
        #else
            let env = "db_production"
        #endif
        return appSupport
            .appendingPathComponent(bundleID, isDirectory: true)
            .appendingPathComponent(env, isDirectory: true)
            .appendingPathComponent("FileLog", isDirectory: true)
    }
}
