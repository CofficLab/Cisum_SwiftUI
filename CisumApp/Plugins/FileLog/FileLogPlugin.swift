import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 磁盘日志插件：通过 OSLogStore 轮询收集日志并写入磁盘文件
///
/// 将原有 `FileLogCoordinator` 的生命周期管理纳入插件系统，
/// 在插件注册时启动日志收集。
///
/// ## 特性
///
/// - 单文件大小上限 5 MB，超限自动轮转
/// - 过期日志自动清理（7 天）
/// - 每 2 秒轮询 OSLogStore
/// - Debug / Release 环境隔离
///
/// ## 设计
///
/// ```text
/// os.Logger → 系统统一日志
///         │
///         ▼
/// FileLogCoordinator（OSLogStore 轮询）
///         │
///         ▼
/// ~/Library/Application Support/com.yueyi.cisum/db_debug/FileLog/
///   ├── 2026-05-26_10-36-00.log
///   └── ...
/// ```
actor FileLogPlugin: SuperPlugin, SuperLog {
    static let shared = FileLogPlugin()
    nonisolated static let emoji = "📋"
    static let verbose = true

    /// 核心系统服务，尽早启动
    static var order: Int { 1 }
    
    /// 默认启用
    static var shouldRegister: Bool { true }

    var instanceLabel: String { "FileLog" }

    let title = "File Log"
    let description = "Collect OSLog entries to disk files with auto-rotation and cleanup"
    let iconName = "doc.text.below.ecg"

    nonisolated func onRegister() {
        if Self.verbose {
            os_log("\(Self.t)📋 磁盘日志插件已注册，启动日志收集")
        }
        FileLogCoordinator.shared.configuration = AppFileLogConfiguration()
        FileLogCoordinator.shared.start()

        // 监听应用终止事件，停止日志收集并 flush 剩余日志
        NotificationCenter.default.addObserver(
            forName: .applicationWillTerminate,
            object: nil,
            queue: nil
        ) { [coordinator = FileLogCoordinator.shared] _ in
            coordinator.stop()
        }
    }
}

/// 应用日志配置：使用 FileManager 直接构建路径（绕过 @MainActor 隔离的 Config）
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
