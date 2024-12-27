import Foundation
import MagicKit
import MagicUI
import OSLog

class BookCopyJob: SuperLog, SuperThread {
    static let emoji = "🔄"
    let db: AudioRecordDB
    let disk: (any SuperStorage)?
    var running = false
    
    init(db: AudioRecordDB, disk: (any SuperStorage)?) {
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
//        Task {
//            for url in urls {
//                await db.newCopyTask(url)
//            }
//
//            self.run()
//        }
    }
    
    func run() {
        let verbose = false

        if running {
            return
        }

        running = true

        if verbose {
            os_log("\(self.t)run")
        }

        guard let disk = self.disk else {
            os_log(.error, "\(self.t)run -> 没有磁盘")
            running = false
            return
        }

//        self.bg.async {
//            Task {
//                let tasks = await self.db.allCopyTasks()
//
//                if tasks.isEmpty {
//                    self.running = false
//                    if verbose {
//                        os_log("\(self.t)run -> 没有任务")
//                    }
//                    return
//                }
//
//                for task in tasks {
//                    do {
//                        let url = task.url
//                        os_log("\(self.t)run -> \(url)")
//                        try disk.copyTo(url: url, reason: "AudioCopyJob")
//                        await self.db.deleteCopyTasks([url])
//                    } catch let e {
//                        await self.db.setTaskError(task, e)
//                    }
//                }
//
//                self.running = false
//            }
//        }
    }
}
