import Foundation
import OSLog
import SwiftData

class CopyFiles {
    var fileManager = FileManager.default
    var queue = DispatchQueue.global(qos: .background)
    var audiosDir = AppConfig.audiosDir
    
    func run(db: DB) throws {
        Task {
            let tasks = await db.allCopyTasks()
            queue.async {
                for task in tasks {
                    Task {
                        do {
                            await db.setTaskRunning(task)
                            try await db.copyTo(task.url)
                            db.delete(task)
                        } catch let e {
                            await db.setTaskError(task, e)
                        }
                    }
                }
            }
        }
    }
}
