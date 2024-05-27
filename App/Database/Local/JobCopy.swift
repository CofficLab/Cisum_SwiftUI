import Foundation
import OSLog
import SwiftData

extension DB {
    func copyFiles() throws {
        Task.detached(priority: .low) {
            let tasks = await self.allCopyTasks()

            for task in tasks {
                Task {
                    do {
                        let context = ModelContext(self.modelContainer)
                        let url = task.url
                        try await self.disk.copyTo(url: url)
                        try context.delete(model: CopyTask.self, where: #Predicate { item in
                            item.url == url
                        })
                        try context.save()
                    } catch let e {
                        await self.setTaskError(task, e)
                    }
                }
            }
        }
    }
}
