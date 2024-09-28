import Foundation
import MagicKit
import OSLog

class AudioCopyJob: SuperLog, SuperThread {
    let emoji = "🔄"
    let db: DB
    let disk: (any Disk)?
    var running = false
    
    init(db: DB, disk: (any Disk)?) {
        self.db = db
        self.disk = disk

        os_log("\(self.t)init")

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
            os_log("\(self.t)run -> 没有磁盘")
            running = false
            return
        }

        self.bg.async {
            Task {
                let tasks = await self.db.allCopyTasks()

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

struct AudioCopyTask {
    let sourcePath: String
    let destinationPath: String
}

enum AudioCopyError: Error {
    case sourceFileNotFound
}
