import Foundation
import OSLog
import MagicKit

class DirectoryStatusChecker: ObservableObject, SuperLog, SuperThread {
    static var emoji: String = "🔍"
    
    @Published private(set) var isChecking = false
    
    // 添加一个通知来传递子项目状态更新
    static let subItemStatusUpdated = Notification.Name("DirectoryStatusChecker.subItemStatusUpdated")
    
    func checkDirectoryStatus(
        _ url: URL,
        downloadProgressCallback: DownloadProgressCallback? = nil
    ) async -> FileStatus.DownloadStatus {
        await MainActor.run { isChecking = true }
        defer { Task { @MainActor in isChecking = false } }
        
        let fileName = url.lastPathComponent
        os_log(.info, "\(self.t)开始检查目录: \(fileName)")
        
        // 先返回检查中状态
        await MainActor.run {
            downloadProgressCallback?(fileName, .checking)
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [
                    .ubiquitousItemIsDownloadingKey,
                    .ubiquitousItemDownloadingStatusKey
                ]
            )
            
            // 创建一个任务组来并行检查所有子项目
            let directoryStatus = await withTaskGroup(of: (String, FileStatus.DownloadStatus).self) { group -> FileStatus.DownloadStatus in
                for item in contents {
                    group.addTask {
                        let status = await self.checkItemStatus(
                            item,
                            downloadProgressCallback: downloadProgressCallback
                        )
                        return (item.path, status)
                    }
                }
                
                // 收集所有子项目的状态
                var statuses: [String: FileStatus.DownloadStatus] = [:]
                for await (path, status) in group {
                    statuses[path] = status
                    // 发送子项目状态更新通知
                    await MainActor.run {
                        NotificationCenter.default.post(
                            name: Self.subItemStatusUpdated,
                            object: (path, status)
                        )
                    }
                }
                
                // 计算目录状态
                var downloaded = 0
                var downloading = 0
                var notDownloaded = 0
                
                for status in statuses.values {
                    switch status {
                    case .notDownloaded:
                        notDownloaded += 1
                    case .downloading:
                        downloading += 1
                    case .downloaded, .local:
                        downloaded += 1
                    case .directoryStatus(_, let subDownloaded, let subDownloading, let subNotDownloaded):
                        downloaded += subDownloaded
                        downloading += subDownloading
                        notDownloaded += subNotDownloaded
                    default:
                        break
                    }
                }
                
                return .directoryStatus(
                    total: contents.count,
                    downloaded: downloaded,
                    downloading: downloading,
                    notDownloaded: notDownloaded
                )
            }
            
            return directoryStatus
            
        } catch {
            os_log(.error, "\(self.t)检查目录失败: \(fileName) - \(error.localizedDescription)")
            return .local
        }
    }
    
    func checkItemStatus(
        _ url: URL,
        downloadProgressCallback: DownloadProgressCallback? = nil,
        verbose: Bool = false
    ) async -> FileStatus.DownloadStatus {
        let resourceValues = try? url.resourceValues(forKeys: [
            .ubiquitousItemIsDownloadingKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemDownloadingErrorKey,
            .isDirectoryKey
        ])
        
        let isDirectory = resourceValues?.isDirectory ?? false
        let fileName = url.lastPathComponent
        
        // 如果是目录，递归检查
        if isDirectory {
            return await checkDirectoryStatus(url, downloadProgressCallback: downloadProgressCallback)
        }
        
        // 单个文件的检查逻辑
        if resourceValues?.ubiquitousItemDownloadingStatus == .current {
            if verbose {
                os_log(.debug, "\(self.t)文件 \(fileName) 状态: 已下载完成")
            }
            return .downloaded
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
                if verbose {
                    os_log(.info, "\(self.t)文件 \(fileName) 状态: 正在下载 (进度: \(Int(progress))%)")
                }
                return .downloading(progress: progress / 100.0)
            } else {
                query.stop()
                if verbose {
                    os_log(.info, "\(self.t)文件 \(fileName) 状态: 正在下载 (进度: 0%)")
                }
                return .downloading(progress: 0)
            }
        } else if resourceValues?.ubiquitousItemDownloadingStatus == .notDownloaded {
            if verbose {
                os_log(.info, "\(self.t)文件 \(fileName) 状态: 未下载")
            }
            return .notDownloaded
        } else {
            if verbose {
                os_log(.debug, "\(self.t)文件 \(fileName) 状态: 本地文件")
            }
            return .local
        }
    }
} 
