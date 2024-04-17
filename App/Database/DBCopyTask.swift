import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    func insert(_ task: CopyTask) {
        context.insert(task)
        try? context.save()
    }

    func add(_ urls: [URL])
    {
        for url in urls {
            add(url)
        }
    }

    func add(_ url: URL) {
        let task = CopyTask(url: url)
        context.insert(task)
        self.save()
        
        do {
            try CopyFiles().run(task, db: self)
        } catch let e {
            task.error = e.localizedDescription
        }
        
        try? context.save()
    }
}

// MARK: 删除

extension DB {
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
            print(e)
        }
    }
}

// MARK: 查询

extension DB {}

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
