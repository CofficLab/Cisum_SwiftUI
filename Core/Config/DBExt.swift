import Foundation
import SwiftUI
import SwiftData

// MARK: 数据库配置

extension Config {
    /// iCloud容器的ID
    static let containerIdentifier = "iCloud.yueyi.cisum"
    
    // MARK: 数据库存储名称
    
    static let dbDirName = debug ? "debug" : "production"
    
    // MARK: 同步的数据库的存储名称
    
    static let syncedDBDirName = debug ? "debug" : "production"
    
    static var syncedDBFileName = debug ? "synced_database.db" : "synced_database.db"

    static func getDBRootDir() -> URL? {
        Config.localDocumentsDir?.appendingPathComponent(dbDirName)
    }
    
    // MARK: 同步的数据库的存储路径
    
    static func getDBSyncedUrl() -> URL? {
        Config.localDocumentsDir?.appendingPathComponent(syncedDBDirName).appendingPathComponent(syncedDBFileName)
    }
    
    // MARK: iCloud 同步的 Container
    
    static var getSyncedContainer: ModelContainer = {
        guard let url = getDBSyncedUrl() else {
            fatalError("Could not create SyncedModelContainer")
        }

        let schema = Schema([
            DeviceData.self,
            BookState.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create SyncedModelContainer: \(error)")
        }
    }()
}
