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

private struct AppFileLogConfiguration: FileLogConfiguration {
    func logsDirectory() -> URL {
        FileLogDirectory.defaultLogsDirectory()
    }
}

#if os(macOS)
final class FileLogTerminationObserver: @unchecked Sendable {
    static let shared = FileLogTerminationObserver()

    private let lock = NSLock()
    private var token: NSObjectProtocol?

    func start(
        notificationCenter: NotificationCenter = .default,
        stop: @escaping @Sendable () -> Void = {
            FileLogCoordinator.shared.stop()
        }
    ) {
        lock.lock()
        defer { lock.unlock() }

        guard token == nil else { return }

        token = notificationCenter.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: nil
        ) { _ in
            stop()
        }
    }

    func stopObserving(notificationCenter: NotificationCenter = .default) {
        lock.lock()
        defer { lock.unlock() }

        guard let token else { return }

        notificationCenter.removeObserver(token)
        self.token = nil
    }
}
#endif
