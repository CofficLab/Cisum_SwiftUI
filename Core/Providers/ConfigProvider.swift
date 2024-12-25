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

    func cancelMigration() {
        isCancelled = true
    }

    func migrateAndUpdateStorageLocation(
        to newLocation: StorageLocation,
        shouldMigrate: Bool,
        progressCallback: ProgressCallback?,
        verbose: Bool
    ) async throws {
        isCancelled = false

        if shouldMigrate {
            // 将所有文件操作放在 Task.detached 中执行
            try await Task.detached(priority: .background) {
                guard let sourceRoot = await self.getStorageRoot() else {
                    throw MigrationError.sourceDirectoryNotFound
                }
                guard let targetRoot = await self.getStorageRoot(for: newLocation) else {
                    throw MigrationError.targetDirectoryNotFound
                }

                let fileManager = FileManager.default
                
                do {
                    var files = try fileManager.contentsOfDirectory(
                        at: sourceRoot,
                        includingPropertiesForKeys: nil
                    )
                    
                    files.sort { $0.lastPathComponent < $1.lastPathComponent }

                    try fileManager.createDirectory(
                        at: targetRoot,
                        withIntermediateDirectories: true
                    )

                    for (index, sourceFile) in files.enumerated() {
                        if await self.isCancelled {
                            throw MigrationError.migrationCancelled
                        }

                        let progress = Double(index + 1) / Double(files.count)
                        let fileName = sourceFile.lastPathComponent
                        
                        // 在后台线程输出日志
                        os_log(.info, "\(self.t)正在迁移: \(fileName) (\(index + 1)/\(files.count))")
                        
                        // 在主线程更新 UI
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
                    os_log(.info, "\(self.t)迁移完成，共处理 \(files.count) 个文件")
                } catch {
                    os_log(.error, "\(self.t)Migration error: \(error.localizedDescription)")
                    if let migrationError = error as? MigrationError {
                        throw migrationError
                    } else {
                        throw MigrationError.fileOperationFailed(error.localizedDescription)
                    }
                }
            }.value

            // 在主线程更新存储位置
            await MainActor.run {
                updateStorageLocation(newLocation)
            }
        } else {
            // 如果不需要迁移，直接更新存储位置
            updateStorageLocation(newLocation)
        }
    }
}
