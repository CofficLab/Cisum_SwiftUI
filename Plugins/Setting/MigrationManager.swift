import Foundation
import OSLog
import MagicKit

typealias ProgressCallback = (Double, String) -> Void
typealias DownloadProgressCallback = (String, FileStatus.DownloadStatus) -> Void

class MigrationManager: ObservableObject, SuperLog, SuperThread {
    static var emoji: String = "👵"
    
    @Published private(set) var isCancelled = false
    
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
            
            let status: FileStatus.DownloadStatus
            let isDirectory = resourceValues?.isDirectory ?? false
            let fileName = url.lastPathComponent
            
            // 如果是目录且需要递归检查
            if isDirectory && isRecursive {
                os_log(.info, "\(self.t)开始检查目录: \(fileName)")
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [
                            .ubiquitousItemIsDownloadingKey,
                            .ubiquitousItemDownloadingStatusKey
                        ]
                    )
                    
                    os_log(.info, "\(self.t)目录 \(fileName) 包含 \(contents.count) 个项目")
                    
                    // 检查所有子项的下载状态
                    var hasNotDownloaded = false
                    var isAnyDownloading = false
                    var downloadingProgress: [Double] = []
                    
                    for (index, item) in contents.enumerated() {
                        // 更新检查进度状态
                        await MainActor.run {
                            downloadProgressCallback?(fileName, .checkingDirectory(fileName, index + 1, contents.count))
                        }
                        
                        os_log(.info, "\(self.t)检查目录 \(fileName) 的第 \(index + 1)/\(contents.count) 个项目")
                        let itemStatus = await self.checkFileDownloadStatus(
                            item,
                            isRecursive: true,
                            downloadProgressCallback: downloadProgressCallback
                        )
                        switch itemStatus {
                        case .notDownloaded:
                            hasNotDownloaded = true
                        case .downloading(let progress):
                            isAnyDownloading = true
                            downloadingProgress.append(progress)
                        default:
                            break
                        }
                    }
                    
                    // 确定目录的整体状态
                    if hasNotDownloaded {
                        status = .notDownloaded
                        os_log(.info, "\(self.t)目录 \(fileName) 状态: 包含未下载文件")
                    } else if isAnyDownloading {
                        let avgProgress = downloadingProgress.reduce(0.0, +) / Double(downloadingProgress.count)
                        status = .downloading(avgProgress)
                        os_log(.info, "\(self.t)目录 \(fileName) 状态: 正在下载 (平均进度: \(Int(avgProgress * 100))%)")
                    } else if resourceValues?.ubiquitousItemDownloadingStatus == .current {
                        status = .downloaded
                        os_log(.info, "\(self.t)目录 \(fileName) 状态: 已全部下载")
                    } else {
                        status = .local
                        os_log(.info, "\(self.t)目录 \(fileName) 状态: 本地目录")
                    }
                } catch {
                    os_log(.error, "\(self.t)检查目录失败: \(fileName) - \(error.localizedDescription)")
                    status = .local
                }
            } else {
                // 单个文件的检查逻辑
                if resourceValues?.ubiquitousItemDownloadingStatus == .current {
                    status = .downloaded
                    os_log(.debug, "\(self.t)文件 \(fileName) 状态: 已下载完成")
                } else if resourceValues?.ubiquitousItemIsDownloading == true {
                    let query = NSMetadataQuery()
                    query.predicate = NSPredicate(format: "%K == %@", 
                        NSMetadataItemPathKey, url.path)
                    query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
                    
                    query.start()
                    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
                    
                    if query.resultCount > 0,
                       let item = query.results.first as? NSMetadataItem {
                        let progress = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0
                        query.stop()
                        status = .downloading(progress / 100.0)
                        os_log(.info, "\(self.t)文件 \(fileName) 状态: 正在下载 (进度: \(Int(progress))%)")
                    } else {
                        query.stop()
                        status = .downloading(0)
                        os_log(.info, "\(self.t)文件 \(fileName) 状态: 正在下载 (进度: 0%)")
                    }
                } else if resourceValues?.ubiquitousItemDownloadingStatus == .notDownloaded {
                    status = .notDownloaded
                    os_log(.info, "\(self.t)文件 \(fileName) 状态: 未下载")
                } else {
                    status = .local
                    os_log(.debug, "\(self.t)文件 \(fileName) 状态: 本地文件")
                }
            }
            
            return status
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