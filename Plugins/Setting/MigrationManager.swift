import Foundation
import OSLog
import MagicKit
import MagicUI

typealias ProgressCallback = (Double, String) -> Void
typealias DownloadProgressCallback = (String, FileStatus.DownloadStatus) -> Void

class MigrationManager: ObservableObject, SuperLog, SuperThread {
    static var emoji: String = "👵"
    
    @Published private(set) var isCancelled = false
    private let statusChecker = DirectoryStatusChecker()
    
    func cancelMigration() {
        isCancelled = true
    }
    
    func checkFileDownloadStatus(
        _ url: URL,
        isRecursive: Bool = true,
        downloadProgressCallback: DownloadProgressCallback? = nil
    ) async -> FileStatus.DownloadStatus {
        return await Task.detached(priority: .background) {
            let resourceValues = try? url.resourceValues(forKeys: [
                .ubiquitousItemIsDownloadingKey,
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemDownloadingErrorKey,
                .isDirectoryKey
            ])
            
            let isDirectory = resourceValues?.isDirectory ?? false
            let fileName = url.lastPathComponent
            
            // 如果是目录且需要递归检查
            if isDirectory && isRecursive {
                return await self.statusChecker.checkDirectoryStatus(
                    url,
                    downloadProgressCallback: downloadProgressCallback
                )
            }
            
            // 单个文件的检查
            return await self.statusChecker.checkItemStatus(
                url,
                downloadProgressCallback: downloadProgressCallback
            )
        }.value
    }
    
    func migrate(
        from sourceRoot: URL,
        to targetRoot: URL,
        progressCallback: ProgressCallback?,
        downloadProgressCallback: DownloadProgressCallback?,
        verbose: Bool
    ) async throws {
        os_log(.info, "\(self.t)开始迁移任务")
        
        do {
            // 获取所有文件并过滤掉 .DS_Store
            var files = try FileManager.default.contentsOfDirectory(
                at: sourceRoot,
                includingPropertiesForKeys: nil
            ).filter { $0.lastPathComponent != ".DS_Store" }
            
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            os_log(.info, "\(self.t)找到 \(files.count) 个待迁移文件（已排除 .DS_Store）")

            try FileManager.default.createDirectory(
                at: targetRoot,
                withIntermediateDirectories: true
            )
            os_log(.info, "\(self.t)已创建目标目录")
            
            // 添加状态统计
            var totalDownloaded = 0
            var totalDownloading = 0
            var totalNotDownloaded = 0
            
            // 先检查所有文件的状态
            for file in files {
                let status = await self.checkFileDownloadStatus(file)
                switch status {
                case .downloaded, .local:
                    totalDownloaded += 1
                case .downloading:
                    totalDownloading += 1
                case .notDownloaded:
                    totalNotDownloaded += 1
                case .directoryStatus(_, let downloaded, let downloading, let notDownloaded):
                    totalDownloaded += downloaded
                    totalDownloading += downloading
                    totalNotDownloaded += notDownloaded
                default:
                    break
                }
            }
            
            os_log(.info, "\(self.t)文件状态统计：\(totalDownloaded)个已下载，\(totalDownloading)个下载中，\(totalNotDownloaded)个未下载")

            for (index, sourceFile) in files.enumerated() {
                if self.isCancelled {
                    os_log(.info, "\(self.t)迁移任务被取消")
                    throw MigrationError.migrationCancelled
                }

                let progress = Double(index + 1) / Double(files.count)
                let fileName = sourceFile.lastPathComponent
                
                // 通知正在检查状态
                await MainActor.run {
                    downloadProgressCallback?(fileName, .checking)
                }
                
                os_log(.info, "\(self.t)检查文件下载状态: \(fileName)")
                let downloadStatus = await self.checkFileDownloadStatus(
                    sourceFile,
                    downloadProgressCallback: downloadProgressCallback
                )
                
                // 通知下载状态
                await MainActor.run {
                    downloadProgressCallback?(fileName, downloadStatus)
                }
                
                if case .notDownloaded = downloadStatus {
                    os_log(.info, "\(self.t)开始下载文件: \(fileName)")
                    try FileManager.default.startDownloadingUbiquitousItem(at: sourceFile)
                }
                
                // 等待并报告下载进度
                while case .downloading = await self.checkFileDownloadStatus(sourceFile) {
                    let currentStatus = await self.checkFileDownloadStatus(sourceFile)
                    await MainActor.run {
                        downloadProgressCallback?(fileName, currentStatus)
                    }
                    os_log(.info, "\(self.t)等待文件下载完成: \(fileName)")
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
                
                os_log(.info, "\(self.t)开始迁移文件: \(fileName) (\(index + 1)/\(files.count))")
                
                await MainActor.run {
                    progressCallback?(progress, fileName)
                }
                
                let targetFile = targetRoot.appendingPathComponent(fileName)
                do {
                    try FileManager.default.moveItem(at: sourceFile, to: targetFile)
                    os_log(.info, "\(self.t)成功迁移: \(fileName)")
                } catch {
                    os_log(.error, "\(self.t)迁移失败: \(fileName) - \(error.localizedDescription)")
                    throw MigrationError.fileOperationFailed("\(fileName): \(error.localizedDescription)")
                }
            }

            try FileManager.default.removeItem(at: sourceRoot)
            os_log(.info, "\(self.t)已删除源目录")
            os_log(.info, "\(self.t)迁移完成，共处理 \(files.count) 个文件")
        } catch {
            os_log(.error, "\(self.t)迁移错误: \(error.localizedDescription)")
            if let migrationError = error as? MigrationError {
                throw migrationError
            } else {
                throw MigrationError.fileOperationFailed(error.localizedDescription)
            }
        }
        
        os_log(.info, "\(self.t)迁移任务结束")
    }
} 