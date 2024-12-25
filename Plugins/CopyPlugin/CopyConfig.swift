import Foundation
import SwiftUI
import SwiftData

struct CopyConfig {
    // MARK: 数据库存储名称
    
    static var dbFileName = "copy_task.db"
        
    // MARK: 本地的数据库的存储路径
    
    static func getDBUrl() -> URL? {
        guard let rootURL = Config.getDBRootDir() else { return nil }
        
        let dbDirURL = rootURL.appendingPathComponent("copy_db")
        
        // 创建目录如果不存在
        do {
            try FileManager.default.createDirectory(at: dbDirURL, withIntermediateDirectories: true)
        } catch {
            print("Error creating directory: \(error)")
            return nil
        }
        
        return dbDirURL.appendingPathComponent(dbFileName)
    }
    
    // MARK: Local Container
    
    static var getContainer: ModelContainer = {
        guard let url = getDBUrl() else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
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
}
