import Foundation
import OSLog

extension Config {
    static let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    static let localContainer = localDocumentsDir?.deletingLastPathComponent()
    static let localDocumentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    
    // MARK: iCloud 容器里的 Documents
    static var cloudDocumentsDir: URL? = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent("Documents")

    static var coverDir: URL {
        if let localDocumentsDir = Config.localDocumentsDir {
            return localDocumentsDir.appendingPathComponent(coversDirName)
        }

        fatalError()
    }
}
