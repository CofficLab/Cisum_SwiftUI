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
            try CopyFiles().run(task, context: context)
        } catch let e {
            task.error = e.localizedDescription
            task.succeed = false
            task.finished = true
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
}

// MARK: 查询

extension DB {}
