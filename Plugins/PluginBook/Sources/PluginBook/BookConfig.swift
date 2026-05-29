import Foundation
import SwiftUI
import SwiftData

public struct BookConfig {
    public static func getDBUrl(dbRootURL: URL) -> URL {
        dbRootURL
            .appendingPathComponent("books_db")
            .appendingPathComponent("books.db")
    }
    
    public static func getCoverFolderUrl(dbRootURL: URL) -> URL {
         dbRootURL
            .appendingPathComponent("books_cover")
    }
 
    public static func getContainer(dbRootURL: URL) throws -> ModelContainer {
        let url = getDBUrl(dbRootURL: dbRootURL)

        let schema = Schema([
            BookModel.self,
            BookState.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            allowsSave: true,
            cloudKitDatabase: .none
        )

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
