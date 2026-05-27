import Combine
import Foundation
import OSLog
import SwiftUI

public extension URL {
    /// 自动判断并监听文件夹变化（支持本地文件夹和 iCloud 文件夹）
    /// - Parameters:
    ///   - verbose: 是否打印详细日志，默认为 true
    ///   - caller: 调用者名称，用于日志标识
    ///   - onChange: 文件夹变化回调
    ///     - files: 文件列表，包含文件夹下所有文件的 URL
    ///     - isInitialFetch: 是否是初始的全量数据。首次获取数据时为 true，后续更新为 false
    ///     - error: 可能发生的错误。如果操作成功，则为 nil
    ///   - onDeleted: 文件被删除的回调
    ///     - urls: 被删除的文件 URL 列表
    ///   - onProgress: iCloud 文件下载进度回调
    ///     - url: 正在下载的文件 URL
    ///     - progress: 下载进度，范围 0.0-1.0
    /// - Returns: 可用于取消监听的 AnyCancellable。调用 cancel() 方法可停止监听
    /// - Note: 对于本地文件夹，使用 FSEvents 进行监听；对于 iCloud 文件夹，使用 NSMetadataQuery 进行监听
    /// - Important: 请确保在不需要监听时调用返回的 AnyCancellable 的 cancel() 方法，以释放资源
    func onDirChange(
        verbose: Bool = true,
        caller: String,
        onChange: @escaping @Sendable (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void,
        onDeleted: @escaping @Sendable (_ urls: [URL]) -> Void = { _ in },
        onProgress: @escaping @Sendable (_ url: URL, _ progress: Double) -> Void = { _, _ in }
    ) -> AnyCancellable {
        if checkIsICloud(verbose: false) {
            if verbose {
                os_log("\(self.t)👀 (\(caller)) 开始监控 iCloud 目录")
                os_log("\(self.t)  • 路径：\(self.shortPath())")
            }

            let monitor = ICloudDirectoryMonitor(
                directoryURL: self,
                verbose: verbose,
                caller: caller,
                onProgress: onProgress,
                onDeleted: onDeleted
            ) { files, isInitial, error in
                Task {
                    await onChange(files, isInitial, error)
                }
            }

            return monitor.start()
        } else {
            if verbose {
                os_log("\(self.t)👀 (\(caller)) 开始监控本地目录")
                os_log("\(self.t)  • 路径：\(self.path())")
            }

            let monitor = LocalDirectoryMonitor(
                directoryURL: self,
                verbose: verbose,
                caller: caller,
                onChange: onChange
            )

            return monitor.start()
        }
    }
}



