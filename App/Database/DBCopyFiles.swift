import Foundation
import OSLog
import SwiftData

extension DB {
    func copyFiles() throws {
        Task {
            let tasks = allCopyTasks()
            queue.async {
                for task in tasks {
                    Task {
                        do {
                            await self.setTaskRunning(task)
                            try await self.copyTo(task.url)
                            self.delete(task)
                        } catch let e {
                            await self.setTaskError(task, e)
                        }
                    }
                }
            }
        }
    }
}
