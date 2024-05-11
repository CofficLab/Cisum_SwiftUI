import Foundation
import OSLog
import SwiftData
import SwiftUI

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

        Task(priority: .high) {
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
//            await self.findDuplicatesJob()
        })
    }

    func setOnUpdated(_ callback: @escaping () -> Void) {
        self.onUpdated = callback
    }

    func hasChanges() -> Bool {
        context.hasChanges
    }

    func getLabel() -> String {
        self.label
    }

    func getDisk() -> DiskContact {
        self.disk
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
            try self.context.save()
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
        return try context.fetch(FetchDescriptor<T>())
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
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
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
