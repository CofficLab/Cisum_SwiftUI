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
            guard let sourceRoot = getStorageRoot() else {
                throw MigrationError.sourceDirectoryNotFound
            }
            guard let targetRoot = getStorageRoot(for: newLocation) else {
                throw MigrationError.targetDirectoryNotFound
            }

            let fileManager = FileManager.default
            
            do {
                let files = try fileManager.contentsOfDirectory(
                    at: sourceRoot,
                    includingPropertiesForKeys: nil
                )

                try fileManager.createDirectory(
                    at: targetRoot,
                    withIntermediateDirectories: true
                )

                for (index, sourceFile) in files.enumerated() {
                    if isCancelled {
                        throw MigrationError.migrationCancelled
                    }

                    let progress = Double(index + 1) / Double(files.count)
                    let fileName = sourceFile.lastPathComponent
                    
                    // 调用回调通知当前处理的文件
                    progressCallback?(progress, fileName)
                    
                    let targetFile = targetRoot.appendingPathComponent(fileName)
                    do {
                        try fileManager.moveItem(at: sourceFile, to: targetFile)
                    } catch {
                        throw MigrationError.fileOperationFailed("\(fileName): \(error.localizedDescription)")
                    }
                }

                try fileManager.removeItem(at: sourceRoot)
            } catch {
                os_log(.error, "\(self.t)Migration error: \(error.localizedDescription)")
                if let migrationError = error as? MigrationError {
                    throw migrationError
                } else {
                    throw MigrationError.fileOperationFailed(error.localizedDescription)
                }
            }
        }

        updateStorageLocation(newLocation)
    }
}
