import Foundation
import OSLog
import SwiftData
import SwiftUI

/**
 DB 负责
 - 对接文件系统
 - 提供 Audio
 - 操作 Audio
 */
actor DB: ModelActor {
    static let label = "📦 DB::"

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var bg = AppConfig.bgQueue
    var queue = DispatchQueue(label: "DB")
    var audiosDir: URL = AppConfig.audiosDir
    var handler = CloudHandler()
    var context: ModelContext
    var dbFolder: DBFolder = .init()
    var onUpdated: () -> Void = { os_log("🍋 DB::updated") }
    var label: String { "\(Logger.isMain)\(DB.label)" }
    var verbose = false

    init(_ container: ModelContainer) {
        if verbose {
            os_log("\(Logger.isMain)🚩 初始化 DB")
        }

        self.modelContainer = container
        self.context = ModelContext(container)
        self.context.autosaveEnabled = false
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: context
        )

        Task.detached(operation: {
            DBSyncJob(db: self).run()
        })

        Task.detached(operation: {
            await DBPrepareJob(db: self).run()
        })

        Task.detached(operation: {
            DBFindDuplicates(db: self).run()
        })
    }

    func setOnUpdated(_ callback: @escaping () -> Void) {
        self.onUpdated = callback
    }

    func hasChanges() -> Bool {
        context.hasChanges
    }

    func save() {
        do {
            try self.context.save()
        } catch let e {
            print(e)
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
