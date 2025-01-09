import Foundation
import SwiftData
import SwiftUI

struct CopyConfig {
    static let dbFileName = "copy_task.db"

    @MainActor static func getDBUrl() throws -> URL {
        try Config.getDBRootDir()
            .appendingPathComponent("copy_db")
            .appendingPathComponent(dbFileName)
            .createIfNotExist()
    }
    
    @MainActor static func getContainer() throws -> ModelContainer {
        let url = try getDBUrl()

        let schema = Schema([
            CopyTask.self,
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
