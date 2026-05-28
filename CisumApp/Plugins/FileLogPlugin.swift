import Foundation
import MagicKit
import OSLog
import PluginFileLog

/// 磁盘日志插件注册适配层；实现位于 Packages/PluginFileLog。
actor FileLogPlugin: SuperPlugin, SuperLog {
    static let shared = FileLogPlugin()
    nonisolated static let emoji = "📋"
    static let verbose = true

    static var order: Int { 1 }
    static var shouldRegister: Bool { true }

    var instanceLabel: String { "FileLog" }

    nonisolated var title: String { FileLogPluginInfo.title }
    nonisolated var description: String { FileLogPluginInfo.description }
    nonisolated var iconName: String { FileLogPluginInfo.iconName }

    nonisolated func onRegister() {
        if Self.verbose {
            os_log("\(Self.t)📋 磁盘日志插件已注册，启动日志收集")
        }
        FileLogCoordinator.shared.configuration = AppFileLogConfiguration()
        FileLogCoordinator.shared.start()

        NotificationCenter.default.addObserver(
            forName: .applicationWillTerminate,
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
