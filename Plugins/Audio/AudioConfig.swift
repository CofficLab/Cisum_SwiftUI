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
    
    static var dbFileName = "audios.db"
    
    static func getCoverFolderUrl() -> URL {
        guard let dir = Config.getDBRootDir()?
            .appendingPathComponent("audios_cover") else {
            fatalError("Could not create cover folder")
        }
          
        return dir
    }
        
    // MARK: 本地的数据库的存储路径
    
    static func getDBUrl() -> URL? {
        guard let baseURL = Config.getDBRootDir() else { return nil }
        
        let dbDirURL = baseURL.appendingPathComponent("audios_db")
        
        // 确保目录存在
        if !FileManager.default.fileExists(atPath: dbDirURL.path) {
            do {
                try FileManager.default.createDirectory(at: dbDirURL, withIntermediateDirectories: true)
            } catch {
                print("创建数据库目录失败: \(error)")
                return nil
            }
        }
        
        return dbDirURL.appendingPathComponent(dbFileName)
    }
    
    // MARK: Local Container
    
    static var getContainer: ModelContainer = {
        guard let url = getDBUrl() else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
            AudioModel.self,
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
}
