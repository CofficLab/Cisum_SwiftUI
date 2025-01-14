import Foundation
import SwiftData
import SwiftUI

@MainActor
struct AudioConfig {
    static func getDBUrl() throws -> URL {
        try Config.getDBRootDir()
            .appendingPathComponent("audios_db")
            .appendingPathComponent("audios.db")
            .createIfNotExist()
    }
    
    static var dbDirName = Config.isDebug ? "audios_debug" : "audios"

    static func getContainer() throws -> ModelContainer {
        let url = try getDBUrl()

        let schema = Schema([
            AudioModel.self,
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
