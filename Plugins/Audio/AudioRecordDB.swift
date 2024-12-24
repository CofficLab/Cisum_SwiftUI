import Foundation
import OSLog
import SwiftData
import SwiftUI
import MagicKit

actor AudioRecordDB: ModelActor, ObservableObject, SuperLog, SuperEvent, SuperThread {
    static let emoji = "📦"
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    let context: ModelContext
    let queue = DispatchQueue(label: "DB")

    init(_ container: ModelContainer, reason: String, verbose: Bool) {
        self.modelContainer = container
        self.context = ModelContext(container)
        self.context.autosaveEnabled = false
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: self.context
        )

        if verbose {
            os_log("\(Self.i) with reason: \(reason)")
        }
    }

    func hasChanges() -> Bool {
        context.hasChanges
    }
}

// MARK: 增加

extension AudioRecordDB {
    func insertModel(_ model: any PersistentModel) throws {
        context.insert(model)
        try context.save()
    }
}

// MARK: 删除

extension AudioRecordDB {
    func destroy<T>(for model: T.Type) throws where T: PersistentModel {
        try context.delete(model: T.self)
    }
}

// MARK: 查询

extension AudioRecordDB {
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

extension AudioRecordDB {
    /// 执行并输出耗时
    func printRunTime(_ title: String, tolerance: Double = 0.1, verbose: Bool = false, _ code: () -> Void) {
        if verbose {
            os_log("\(self.t)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if verbose && timeInterval > tolerance {
            os_log("\(self.t)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
        }
    }
    
    nonisolated func jobEnd(_ startTime: DispatchTime, title: String, tolerance: Double = 1.0) -> String {
        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if timeInterval > tolerance {
            return "\(title) \(timeInterval) 秒 🐢🐢🐢"
        }
        
        return "\(title) \(timeInterval) 秒 🐢🐢🐢"
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
