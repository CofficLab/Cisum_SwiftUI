import Foundation
import OSLog

extension AppConfig {
    static let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    static let localContainer = localDocumentsDir?.deletingLastPathComponent()
    static let localDocumentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    
    // MARK: iCloud 容器路径
    static let containerDir = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)
    
    // MARK: iCloud 容器里的 Documents
    static var cloudDocumentsDir: URL {
        if let c = containerDir {
            return c.appending(component: "Documents")
        }

        fatalError()
    }

    static var coverDir: URL {
        if let localDocumentsDir = AppConfig.localDocumentsDir {
            return localDocumentsDir.appendingPathComponent(coversDirName)
        }

        fatalError()
    }
    
    // MARK: 音频存储目录

    static var audiosDir: URL {
        var cloudURL = AppConfig.cloudDocumentsDir.appendingPathComponent(AppConfig.audiosDirName)
        var localURL = AppConfig.localDocumentsDir!.appendingPathComponent(AppConfig.audiosDirName)
        let url = iCloudEnabled ? cloudURL : localURL

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("\(Logger.isMain)🍋 DB::创建 Audios 目录成功")
            } catch {
                os_log("\(Logger.isMain)创建 Audios 目录失败\n\(error.localizedDescription)")
            }
        }

        return url
    }

    static var trashDir: URL {
        let url = AppConfig.cloudDocumentsDir.appendingPathComponent(AppConfig.trashDirName)

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("\(Logger.isMain)🍋 DB::创建回收站目录成功")
            } catch {
                os_log("\(Logger.isMain)创建回收站目录失败\n\(error.localizedDescription)")
            }
        }

        return url
    }
}
