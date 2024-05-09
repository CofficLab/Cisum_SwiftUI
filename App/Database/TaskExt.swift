import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    func insertCopyTask(_ task: CopyTask) {
        context.insert(task)
        try? context.save()
    }

    func addCopyTasks(_ urls: [URL]) {
        for url in urls {
            newCopyTask(url)
        }
    }

    /// 将文件从外部复制到应用中
    func newCopyTask(_ url: URL) {
        if (self.findCopyTask(url) != nil) {
            return
        }

        let task = CopyTask(url: url)
        context.insert(task)
        self.save()
    }
}

// MARK: 删除

extension DB {
    func deleteCopyTask(_ id: CopyTask.ID) {
        os_log("\(Logger.isMain)\(DB.label)数据库删除")
        let context = ModelContext(modelContainer)
        guard let task = context.model(for: id) as? CopyTask else {
            os_log("\(Logger.isMain)\(DB.label)删除时数据库找不到")
            return
        }

        do {
            context.delete(task)

            try context.save()
            os_log("\(Logger.isMain)\(DB.label)删除成功")
        } catch let e {
            os_log("\(Logger.isMain)\(DB.label)删除出错 \(e)")
        }
    }

    func deleteCopyTasks(_ urls: [URL]) {
        try? self.context.delete(model: CopyTask.self, where: #Predicate {
            urls.contains($0.url)
        })

        self.save()
    }

    nonisolated func delete(_ task: CopyTask) {
        os_log("\(Logger.isMain)🗑️ 删除复制任务 \(task.title)")
        let context = ModelContext(modelContainer)
        guard let t = context.model(for: task.id) as? CopyTask else {
            return os_log("\(Logger.isMain)🗑️ 删除时数据库找不到 \(task.title)")
        }

        do {
            context.delete(t)
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

// MARK: 查询

extension DB {
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
}

// MARK: 更新

extension DB {
    func setTaskRunning(_ task: CopyTask) {
        task.isRunning = true
        task.error = ""
        self.save()
    }

    func setTaskError(_ task: CopyTask, _ e: Error) {
        task.isRunning = false
        task.error = e.localizedDescription
        self.save()
    }
}
