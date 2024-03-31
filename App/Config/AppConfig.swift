import Foundation
import OSLog

struct AppConfig {
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let coversDirName = "covers"
    static let audiosDirName = "audios"
    static let cacheDirName = "audios_cache"
    static let containerIdentifier = "iCloud.yueyi.cisum"
    static let logger = Logger.self
}

// MARK: 视图配置

extension AppConfig {
    /// 上半部分播放控制的高度
    static var controlViewHeight: CGFloat = 160
}

// MARK: 队列配置

extension AppConfig {
    static let mainQueue = DispatchQueue.main
    static let bgQueue = DispatchQueue(label: "com.yueyi.bgqueue")
}

// MARK: 路径配置

extension AppConfig {
    static let documentsDir = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)!.appending(component: "Documents")
    
    static var coverDir: URL {
        documentsDir.appendingPathComponent(coversDirName)
    }
    
    static var audiosDir: URL {
        let url = AppConfig.documentsDir.appendingPathComponent(AppConfig.audiosDirName)
        
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
}
