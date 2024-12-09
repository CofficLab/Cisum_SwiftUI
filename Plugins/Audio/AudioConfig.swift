import Foundation
import SwiftUI
import SwiftData

struct AudioConfig {
    /// iCloud容器的ID
    static let containerIdentifier = "iCloud.yueyi.cisum"
    
    /// 封面图文件夹
    static let coversDirName = "covers"
    
    /// 回收站文件夹
    static let trashDirName = "trash"
    
    /// 缓存文件夹
    static let cacheDirName = "audios_cache"
    
    // MARK: 数据库存储名称
    
    static let dbDirName = Config.debug ? "debug" : "production"
    
    static var dbFileName = Config.debug ? "database.db" : "database.db"
    
    // MARK: 同步的数据库的存储名称
    
    static let syncedDBDirName = Config.debug ? "debug" : "production"
    
    static var syncedDBFileName = Config.debug ? "synced_database.db" : "synced_database.db"
        
    // MARK: 本地的数据库的存储路径
    
    static func getDBUrl() -> URL? {
        Config.localDocumentsDir?.appendingPathComponent(dbDirName).appendingPathComponent(dbFileName)
    }
    
    // MARK: 同步的数据库的存储路径
    
    static func getDBSyncedUrl() -> URL? {
        Config.localDocumentsDir?.appendingPathComponent(syncedDBDirName).appendingPathComponent(syncedDBFileName)
    }
    
    // MARK: Local Container
    
    static var getContainer: ModelContainer = {
        guard let url = getDBUrl() else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
            Audio.self,
            Book.self,
            Cover.self,
            CopyTask.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            allowsSave: true,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
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
