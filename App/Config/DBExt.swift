import Foundation
import SwiftUI
import SwiftData

// MARK: 数据库配置

extension AppConfig {
    static var dbFileName = debug ? "database_debug.db" : "database.db"
    
    static let audiosDirName = debug ? "audios_debug" : "audios"
    
    static func getDBUrl() -> URL? {
        if debug {
            AppConfig.localDocumentsDir?.appendingPathComponent("debug").appendingPathComponent(dbFileName)
        } else {
            AppConfig.localDocumentsDir?.appendingPathComponent(dbFileName)
        }
    }
    
    static func getContainer() -> ModelContainer {
        guard let url = getDBUrl() else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
            Audio.self,
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
    }
}
