import Foundation
import OSLog

extension Config {
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
        if let localDocumentsDir = Config.localDocumentsDir {
            return localDocumentsDir.appendingPathComponent(coversDirName)
        }

        fatalError()
    }
    
    static var trashDir: URL {
        let url = Config.cloudDocumentsDir.appendingPathComponent(Config.trashDirName)

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
