import Foundation
import OSLog
import SwiftData
import SwiftUI
import MagicKit

actor BookRecordDB: ModelActor, ObservableObject, SuperLog, SuperEvent, SuperThread {
    static let label = "📦 DB::"
    let emoji = "🎁"
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    let context: ModelContext
    let queue = DispatchQueue(label: "DB")
    var onUpdated: () -> Void = { os_log("🍋 DB::updated") }

    init(_ container: ModelContainer, reason: String, verbose: Bool = false) {
        if verbose {
            let message = "\(Logger.isMain)\(Self.label)🚩🚩🚩 初始化(\(reason))"
            
            os_log("\(message)")
        }

        modelContainer = container
        context = ModelContext(container)
        context.autosaveEnabled = false
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: context
        )
    }

    func setOnUpdated(_ callback: @escaping () -> Void) {
        onUpdated = callback
    }

    func hasChanges() -> Bool {
        context.hasChanges
    }
}

// MARK: 增加

extension BookRecordDB {
    func insertModel(_ model: any PersistentModel) throws {
        context.insert(model)
        try context.save()
    }
}

// MARK: 删除

extension BookRecordDB {
    func destroy<T>(for model: T.Type) throws where T: PersistentModel {
        try context.delete(model: T.self)
    }
}

// MARK: 查询

extension BookRecordDB {
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

extension BookRecordDB {
    /// 执行并输出耗时
    func printRunTime(_ title: String, tolerance: Double = 0.1, verbose: Bool = false, _ code: () -> Void) {
        if verbose {
            os_log("\(Logger.isMain)\(AudioRecordDB.label)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if verbose && timeInterval > tolerance {
            os_log("\(Logger.isMain)\(AudioRecordDB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
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

extension BookRecordDB {
    static func first(context: ModelContext) -> Book? {
        var descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> {
            $0.title != ""
        }, sortBy: [
            SortDescriptor(\.order, order: .forward),
        ])
        descriptor.fetchLimit = 1

        do {
            return try context.fetch(descriptor).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
    
    static func nextOf(context: ModelContext, book: Book) -> Book? {
         os_log("🍋 DB::nextOf [\(book.order)] \(book.title)")
        let order = book.order
        let url = book.url
        var descriptor = FetchDescriptor<Book>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order >= order && $0.url != url
        }

        do {
            let result = try context.fetch(descriptor)
            let next = result.first ?? Self.first(context: context)
            // os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> [\(next?.order ?? -1)] \(next?.title ?? "-")")
            return next
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    func delete(ids: [Book.ID],verbose: Bool) -> Book? {
        if verbose {
            os_log("\(self.t)删除")
        }

        // 本批次的最后一个删除后的下一个
        var next: Book?

        for (index, id) in ids.enumerated() {
            guard let book = context.model(for: id) as? Book else {
                os_log(.error, "\(self.t)删除时找不到")
                continue
            }

            let url = book.url

            // 找出本批次的最后一个删除后的下一个
            if index == ids.count - 1 {
                next = Self.nextOf(context: context, book: book)

                // 如果下一个等于当前，设为空
                if next?.url == url {
                    next = nil
                }
            }

            do {
                context.delete(book)
                try context.save()
            } catch let e {
                os_log(.error, "\(Logger.isMain)\(AudioRecordDB.label)删除出错 \(e)")
            }
        }

        return next
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
