import Foundation
import SwiftUI
import SwiftData

struct BookConfig {
    // MARK: 数据库存储名称
    
    @MainActor static var dbFileName = "books.db"
        
    // MARK: 本地的数据库的存储路径
    
    @MainActor static func getDBUrl() -> URL? {
        Config.getDBRootDir()?
            .appendingPathComponent("books_db")
            .appendingPathComponent(dbFileName)
    }
    
    @MainActor static func getCoverFolderUrl() -> URL {
        guard let dir = Config.getDBRootDir()?
            .appendingPathComponent("books_cover") else {
            fatalError("Could not create cover folder")
        }
          
        return dir
    }
    
    // MARK: Local Container
    
    @MainActor
    static let getContainer: ModelContainer = {
        guard let url = getDBUrl() else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
            Book.self,
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
