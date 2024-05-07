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

    var queue = DispatchQueue(label: "DB")
    var context: ModelContext
    var disk: DiskContact = DiskiCloud()
    var onUpdated: () -> Void = { os_log("🍋 DB::updated") }
    var label: String { "\(Logger.isMain)\(DB.label)" }
    var verbose = true

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
            await self.sync()
        })

        Task.detached(operation: {
            await self.prepareJob()
        })

        Task.detached(operation: {
            await self.findDuplicatesJob()
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
    
    func getLabel() -> String {
        self.label
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
