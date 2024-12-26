import Foundation
import OSLog
import MagicKit

class DirectoryStatusChecker: ObservableObject, SuperLog, SuperThread {
    static var emoji: String = "🔍"
    
    @Published private(set) var isChecking = false
    
    func checkDirectoryStatus(
        _ url: URL,
        downloadProgressCallback: DownloadProgressCallback? = nil
    ) async -> FileStatus.DownloadStatus {
        await MainActor.run { isChecking = true }
        defer { Task { @MainActor in isChecking = false } }
        
        let resourceValues = try? url.resourceValues(forKeys: [
            .ubiquitousItemIsDownloadingKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemDownloadingErrorKey,
            .isDirectoryKey
        ])
        
        let fileName = url.lastPathComponent
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
            var downloaded = 0
            var downloading = 0
            var notDownloaded = 0
            
            for (index, item) in contents.enumerated() {
                // 更新检查进度状态
                await MainActor.run {
                    downloadProgressCallback?(fileName, .checkingDirectory(fileName, index + 1, contents.count))
                }
                
                os_log(.info, "\(self.t)检查目录 \(fileName) 的第 \(index + 1)/\(contents.count) 个项目")
                let itemStatus = await checkItemStatus(item, downloadProgressCallback: downloadProgressCallback)
                switch itemStatus {
                case .notDownloaded:
                    hasNotDownloaded = true
                    notDownloaded += 1
                case .downloading(let progress):
                    isAnyDownloading = true
                    downloadingProgress.append(progress)
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
            
            // 返回目录状态
            return .directoryStatus(
                total: contents.count,
                downloaded: downloaded,
                downloading: downloading,
                notDownloaded: notDownloaded
            )
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
