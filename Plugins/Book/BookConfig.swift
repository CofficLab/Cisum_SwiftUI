import Foundation
import SwiftUI
import SwiftData

struct BookConfig {
    // MARK: 数据库存储名称
    
    static var dbFileName = "books.db"
        
    // MARK: 本地的数据库的存储路径
    
    static func getDBUrl() -> URL? {
        Config.getDBRootDir()?
            .appendingPathComponent("books_db")
            .appendingPathComponent(dbFileName)
    }
    
    // MARK: Local Container
    
    static var getContainer: ModelContainer = {
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