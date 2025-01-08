import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

actor CopyDB: ModelActor, ObservableObject, SuperLog, SuperEvent, SuperThread {
    static let emoji = "🛖"
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    let context: ModelContext
    let queue = DispatchQueue(label: "DB")
    var onUpdated: () -> Void = { os_log("🍋 DB::updated") }

    init(_ container: ModelContainer, reason: String, verbose: Bool) {
        if verbose {
            os_log("\(Self.i) 🐛 \(reason)")
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

    func insertCopyTask(_ task: CopyTask) {
        context.insert(task)
        try? context.save()
    }

    func addCopyTasks(_ urls: [URL], folder: URL) {
        let verbose = true
        if verbose {
            os_log("\(self.t)添加复制任务(\(urls.count)个)")
        }

        for url in urls {
            newCopyTask(url, destination: folder.appendingPathComponent(url.lastPathComponent))
        }
    }

    /// 将文件从外部复制到应用中
    func newCopyTask(_ url: URL, destination: URL) {
        if self.findCopyTask(url) != nil {
            return
        }

        let task = CopyTask(url: url, destination: destination)
        context.insert(task)
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func deleteCopyTask(_ id: CopyTask.ID) {
        os_log("\(self.t)数据库删除")
        let context = ModelContext(modelContainer)
        guard let task = context.model(for: id) as? CopyTask else {
            os_log("\(self.t)删除时数据库找不到")
            return
        }

        do {
            context.delete(task)

            try context.save()
            os_log("\(self.t)删除成功")
        } catch let e {
            os_log("\(self.t)删除出错 \(e)")
        }
    }

    func deleteCopyTasks(_ urls: [URL]) {
        try? self.context.delete(model: CopyTask.self, where: #Predicate {
            urls.contains($0.url)
        })

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    nonisolated func delete(_ task: CopyTask) {
        // os_log("\(Logger.isMain)🗑️ 删除复制任务 \(task.title)")
        let context = ModelContext(modelContainer)
        guard let t = context.model(for: task.id) as? CopyTask else {
            return os_log("\(self.t)🗑️ 删除时数据库找不到 \(task.title)")
        }

        do {
            context.delete(t)
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func allCopyTasks() -> [CopyTask] {
        let descriptor = FetchDescriptor<CopyTask>()
        do {
            return try context.fetch(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return []
    }

    func findCopyTask(_ url: URL) -> CopyTask? {
        let predicate = #Predicate<CopyTask> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<CopyTask>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    func setTaskRunning(_ task: CopyTask) {
        task.isRunning = true
        task.error = ""
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func setTaskError(_ task: CopyTask, _ e: Error) {
        task.isRunning = false
        task.error = e.localizedDescription
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func setTaskError(url: URL, error: String) {
        if let task = findCopyTask(url) {
            setTaskError(task, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error]))
        }
    }

    func allCopyTaskDTOs() async -> [CopyTaskDTO] {
        allCopyTasks().map { CopyTaskDTO(from: $0) }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
