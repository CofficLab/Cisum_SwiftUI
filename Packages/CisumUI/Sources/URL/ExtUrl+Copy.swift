import Foundation
import OSLog
import SwiftUI

public extension URL {
    /// 复制文件到目标位置，支持 iCloud 文件的自动下载
    /// - Parameters:
    ///   - destination: 目标位置
    ///   - verbose: 是否打印详细日志，默认为 false
    ///   - reason: 复制原因，用于日志记录
    ///   - downloadMethod: 下载方式，默认为 .polling
    ///   - downloadProgress: 下载进度回调
    func copyTo(
        _ destination: URL,
        verbose: Bool = true,
        caller: String,
        downloadMethod: DownloadMethod = .polling(),
        downloadProgress: ((Double) -> Void)? = nil
    ) async throws {
        if verbose {
            let sourcePath = (self.pathComponents.suffix(3)).joined(separator: "/")
            let destPath = (destination.pathComponents.suffix(3)).joined(separator: "/")
            os_log("\(self.t)👷 (\(caller)) 开始复制文件: .../\(sourcePath) -> .../\(destPath)")
        }

        // 只有在需要显示下载进度时才手动处理下载
        if let downloadProgress, self.checkIsICloud(verbose: false) && self.isNotDownloaded {
            try await download(
                verbose: verbose,
                reason: caller + "-> URL.copyTo",
                method: downloadMethod,
                onProgress: downloadProgress
            )
        }
        
        if verbose {
            os_log("\(self.t)🚛 执行文件复制操作（自动下载），当前下载状态：\(self.isDownloaded)")
        }
        try FileManager.default.copyItem(at: self, to: destination)
        if verbose {
            os_log("\(self.t)✅ 文件复制完成")
        }
    }
}

#if DEBUG
#Preview("Copy View") {
    CopyViewPreviewContainer()
}
#endif
