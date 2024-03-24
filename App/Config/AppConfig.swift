import Foundation
import OSLog

struct AppConfig {
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let coversDirName = "covers"
    static let audiosDirName = "audios"
    static let cacheDirName = "audios_cache"
    static let container = "iCloud.yueyi.cisum"
    static let logger = Logger.self
}

// MARK: 队列配置

extension AppConfig {
    static let mainQueue = DispatchQueue.main
    static let bgQueue = DispatchQueue(label: "com.yueyi.bgqueue")
}

// MARK: 路径配置

extension AppConfig {
    static let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    static var coverDir: URL {
        documentsDir.appendingPathComponent(coversDirName)
    }
}
