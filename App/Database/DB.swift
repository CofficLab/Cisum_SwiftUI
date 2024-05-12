import Foundation
import OSLog
import SwiftData
import SwiftUI

actor DB: ModelActor {
    static let label = "📦 DB::"
    static let verbose = true
    static var lastSyncedTime: Date = .distantPast
    static var findDuplicatesJobProcessing: Bool = false
    static var shouldStopJob = false

    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    var queue = DispatchQueue(label: "DB")
    var context: ModelContext
    var disk: DiskContact = DiskiCloud()
    var sync: Bool = false
    var onUpdated: () -> Void = { os_log("🍋 DB::updated") }
    var label: String { "\(Logger.isMain)\(DB.label)" }
    var verbose: Bool { DB.verbose }

    init(_ container: ModelContainer, sync: Bool = false) {
        if DB.verbose {
            os_log("\(Logger.isMain)🚩 初始化 DB")
        }

        modelContainer = container
        context = ModelContext(container)
        context.autosaveEnabled = false
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: context
        )

        if sync {
            Task(priority: .high) {
                await self.disk.onUpdated = { items in
                    Task {
                        await self.sync(items)
                    }
                }

                await self.disk.watchAudiosFolder()
            }
        }
    }

    func setOnUpdated(_ callback: @escaping () -> Void) {
        onUpdated = callback
    }

    func hasChanges() -> Bool {
        context.hasChanges
    }

    func getLabel() -> String {
        label
    }

    func getDisk() -> DiskContact {
        disk
    }
}

// MARK: 增加

extension DB {
    func insertModel(_ model: any PersistentModel) throws {
        context.insert(model)
        try context.save()
    }
}

// MARK: 删除

extension DB {
    func destroy<T>(for model: T.Type) throws where T: PersistentModel {
        try context.delete(model: T.self)
    }
}

// MARK: 修改

extension DB {
    func save() {
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func save(_ completion: @escaping (Error?) -> Void) {
        do {
            try context.save()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
}

// MARK: 查询

extension DB {
    /// 所有指定的model
    func all<T: PersistentModel>() throws -> [T] {
        try context.fetch(FetchDescriptor<T>())
    }

    /// 分页的方式查询model
    func paginate<T: PersistentModel>(page: Int) throws -> [T] {
        try context.fetch(FetchDescriptor<T>())
    }

    /// 获取指定条件的数量
    func getCount<T: PersistentModel>(for predicate: Predicate<T>) throws -> Int {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try context.fetchCount(descriptor)
    }

    /// 按照指定条件查询多个model
    func get<T: PersistentModel>(for predicate: Predicate<T>) throws -> [T] {
        // os_log("\(self.isMain) 🏠 LocalDB.get")
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try context.fetch(descriptor)
    }

    /// 某个model的总条数
    func count<T>(for model: T.Type) throws -> Int where T: PersistentModel {
        let descriptor = FetchDescriptor<T>(predicate: .true)
        return try context.fetchCount(descriptor)
    }
}

// MARK: 辅助类函数

extension DB {
    /// 执行并输出耗时
    nonisolated func printRunTime(_ title: String, tolerance: Double = 1, _ code: () -> Void) {
        if DB.verbose {
            os_log("\(Logger.isMain)\(DB.label)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if DB.verbose && timeInterval > tolerance {
            os_log("\(Logger.isMain)\(DB.label)\(title) 🐢🐢🐢 cost \(timeInterval) 秒")
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
