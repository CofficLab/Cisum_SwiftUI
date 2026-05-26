import Foundation

/// 磁盘日志配置协议
public protocol FileLogConfiguration: Sendable {
    /// 返回日志存储目录
    func logsDirectory() -> URL
}

/// 默认日志配置：使用 Cisum 的数据库目录下插件专属子目录
struct DefaultFileLogConfiguration: FileLogConfiguration {
    func logsDirectory() -> URL {
        // 绕过 @MainActor 隔离的 Config，直接使用 FileManager
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
