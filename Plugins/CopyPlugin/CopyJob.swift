import Foundation
import MagicKit
import OSLog

class CopyJob: SuperLog, SuperThread, ObservableObject {
    static let emoji = "🔄"
    
    let db: CopyDB
    let disk: (any SuperDisk)?
    var running = false
    
    init(db: CopyDB, disk: (any SuperDisk)?) {
        self.db = db
        self.disk = disk

        let verbose = false
        if verbose {
            os_log("\(self.t)init")
        }

        self.bg.async {
            self.run()
        }
    }

    func append(_ urls: [URL]) {
        Task {
            for url in urls {
                await db.newCopyTask(url)
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

        guard let disk = self.disk else {
            os_log(.error, "\(self.t)没有磁盘")
            running = false
            return
        }

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
                        os_log("\(self.t)run -> \(url)")
                        try disk.copyTo(url: url, reason: "AudioCopyJob")
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