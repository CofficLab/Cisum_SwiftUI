import Foundation
import SwiftUI
import OSLog

extension Config {
    static let containerIdentifier = "iCloud.yueyi.cisum"
    
    static let dbDirName = debug ? "db_debug" : "db_production"

    static func getDBRootDir() -> URL? {
        guard let url = Config.appSupportDir?
            .appendingPathComponent("Cisum_Database")
            .appendingPathComponent(dbDirName) else { return nil }
        
        // 如果目录不存在则创建
        if !FileManager.default.fileExists(atPath: url.path) {
            os_log("\(self.t) Creating database directory: \(url.path)")
            
            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }
        
        return url
    }
}
