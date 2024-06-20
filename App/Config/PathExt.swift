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
}
