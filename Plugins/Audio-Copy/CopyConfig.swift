import Foundation
import SwiftData
import SwiftUI

struct CopyConfig {
    static let dbFileName = "copy_task.db"

    @MainActor static func getContainer() throws -> ModelContainer {
        let url = try Config.createDatabaseFile(name: "copy_db")

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

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
