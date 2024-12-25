import AVKit
import Combine
import Foundation
import MagicKit
import MediaPlayer
import OSLog
import SwiftUI

enum StorageLocation: String, Codable {
    case icloud
    case local
    case custom

    var emojiTitle: String {
        self.emoji + " " + self.title
    }

    var emoji: String {
        switch self {
        case .icloud: return "🌐"
        case .local: return "💾"
        case .custom: return "🔧"
        }
    }

    var title: String {
        switch self {
        case .icloud: return "iCloud"
        case .local: return "本地"
        case .custom: return "自定义"
        }
    }

    var description: String {
        switch self {
        case .icloud: return "使用iCloud存储数据"
        case .local: return "使用本地存储数据"
        case .custom: return "使用自定义存储数据"
        }
    }
}

enum MigrationError: LocalizedError {
    case sourceDirectoryNotFound
    case targetDirectoryNotFound
    case fileOperationFailed(String)
    case migrationCancelled
    
    var errorDescription: String? {
        switch self {
        case .sourceDirectoryNotFound:
            return "无法找到源文件夹"
        case .targetDirectoryNotFound:
            return "无法找到目标文件夹"
        case .fileOperationFailed(let message):
            return "文件操作失败: \(message)"
        case .migrationCancelled:
            return "迁移已取消，部分文件可能已经迁移"
        }
    }
}

@MainActor
class ConfigProvider: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog, SuperThread {
    static let emoji: String = "🔩"
    static let keyOfStorageLocation = "StorageLocation"

    @Published var storageLocation: StorageLocation?

    private var isCancelled = false

    override init() {
        super.init()
        // 从 UserDefaults 加载存储位置设置
        if let savedLocation = UserDefaults.standard.string(forKey: Self.keyOfStorageLocation),
           let location = StorageLocation(rawValue: savedLocation) {
            self.storageLocation = location
        }
    }

    func updateStorageLocation(_ location: StorageLocation?) {
        self.storageLocation = location
        // 保存到 UserDefaults
        UserDefaults.standard.set(location?.rawValue, forKey: Self.keyOfStorageLocation)
    }

    func getStorageLocation() -> StorageLocation? {
        return self.storageLocation
    }

    func getStorageRoot() -> URL? {
        switch self.storageLocation {
        case .icloud:
            return Config.cloudDocumentsDir
        case .local:
            return Config.localDocumentsDir
        default:
            return nil
        }
    }

    func getStorageRoot(for location: StorageLocation) -> URL? {
        switch location {
        case .icloud:
            return Config.cloudDocumentsDir
        case .local:
            return Config.localDocumentsDir
        case .custom:
            return nil // 或者返回自定义的路径
        }
    }

    typealias ProgressCallback = (Double, String) -> Void
    typealias DownloadProgressCallback = (String, FileStatus.DownloadStatus) -> Void

    func cancelMigration() {
        isCancelled = true
    }

    private func checkFileDownloadStatus(
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

    func migrateAndUpdateStorageLocation(
        to newLocation: StorageLocation,
        shouldMigrate: Bool,
        progressCallback: ProgressCallback?,
        downloadProgressCallback: DownloadProgressCallback?,
        verbose: Bool
    ) async throws {
        self.isCancelled = false
        os_log(.info, "\(self.t)开始迁移任务")

        if shouldMigrate {
            try await Task.detached(priority: .background) {
                guard let sourceRoot = await self.getStorageRoot() else {
                    os_log(.error, "\(self.t)源目录未找到")
                    throw MigrationError.sourceDirectoryNotFound
                }
                guard let targetRoot = await self.getStorageRoot(for: newLocation) else {
                    os_log(.error, "\(self.t)目标目录未找到")
                    throw MigrationError.targetDirectoryNotFound
                }

                os_log(.info, "\(self.t)源目录: \(sourceRoot.path)")
                os_log(.info, "\(self.t)目标目录: \(targetRoot.path)")

                let fileManager = FileManager.default
                
                do {
                    // 获取所有文件并过滤掉 .DS_Store
                    var files = try fileManager.contentsOfDirectory(
                        at: sourceRoot,
                        includingPropertiesForKeys: nil
                    ).filter { $0.lastPathComponent != ".DS_Store" }
                    
                    files.sort { $0.lastPathComponent < $1.lastPathComponent }
                    os_log(.info, "\(self.t)找到 \(files.count) 个待迁移文件（已排除 .DS_Store）")

                    try fileManager.createDirectory(
                        at: targetRoot,
                        withIntermediateDirectories: true
                    )
                    os_log(.info, "\(self.t)已创建目标目录")

                    for (index, sourceFile) in files.enumerated() {
                        if await self.isCancelled {
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
                        
                        // 通知载状态
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
                            try fileManager.moveItem(at: sourceFile, to: targetFile)
                            os_log(.info, "\(self.t)成功迁移: \(fileName)")
                        } catch {
                            os_log(.error, "\(self.t)迁移失败: \(fileName) - \(error.localizedDescription)")
                            throw MigrationError.fileOperationFailed("\(fileName): \(error.localizedDescription)")
                        }
                    }

                    try fileManager.removeItem(at: sourceRoot)
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
            }.value

            await MainActor.run {
                os_log(.info, "\(self.t)更新存储位置设置")
                self.updateStorageLocation(newLocation)
            }
        } else {
            os_log(.info, "\(self.t)跳过迁移，直接更新存储位置")
            self.updateStorageLocation(newLocation)
        }
        
        os_log(.info, "\(self.t)迁移任务结束")
    }
}
