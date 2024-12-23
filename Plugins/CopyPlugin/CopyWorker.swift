import Foundation
import MagicKit
import OSLog

class CopyWorker: SuperLog, SuperThread, ObservableObject {
    static let emoji = "👷"
    
    let db: CopyDB
    var running = false
    
    init(db: CopyDB) {
        self.db = db
        
        let verbose = false
        if verbose {
            os_log("\(self.t)init")
        }
        
        self.bg.async {
            self.run()
        }
    }
    
    func append(_ urls: [URL], folder: URL) {
        Task {
            for url in urls {
                await db.newCopyTask(url, destination: folder)
            }
            
            self.run()
        }
    }

    
    func run() {
        if running {
            return
        }

        running = true

        os_log("\(self.t)run")

        self.bg.async {
            Task {
                let tasks = await self.db.allCopyTasks()

                if tasks.isEmpty {
                    self.running = false
                    os_log("\(self.t)没有任务")
                    return
                }

                for task in tasks {
                    do {
                        let url = task.url
                        os_log("\(self.t)run -> \(url.path(percentEncoded: false)) -> \(task.destination.path(percentEncoded: false))")
                        try FileManager.default.copyItem(at: url, to: task.destination.appendingPathExtension(url.lastPathComponent))
                        await self.db.deleteCopyTasks([url])
                    } catch let e {
                        await self.db.setTaskError(task, e)
                    }
                }

                self.running = false
            }
        }
    }
}
