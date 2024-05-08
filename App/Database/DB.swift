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
    static let verbose = true

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    var queue = DispatchQueue(label: "DB")
    var context: ModelContext
    var disk: DiskContact = DiskiCloud()
    var onUpdated: () -> Void = { os_log("🍋 DB::updated") }
    var label: String { "\(Logger.isMain)\(DB.label)" }
    var verbose: Bool { DB.verbose }

    init(_ container: ModelContainer) {
        if DB.verbose {
            os_log("\(Logger.isMain)🚩 初始化 DB")
        }

        self.modelContainer = container
        self.context = ModelContext(container)
        self.context.autosaveEnabled = false
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: context
        )

        Task {
            await self.disk.onUpdated = { items in
                Task {
                    await self.sync(items)
                }
            }

            await self.disk.watchAudiosFolder()
        }

        Task {
            await self.prepareJob()
        }

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

    func getDisk() -> DiskContact {
        self.disk
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
