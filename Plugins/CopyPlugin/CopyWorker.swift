import Foundation
import MagicKit
import MagicUI
import OSLog

class CopyWorker: SuperLog, SuperThread, ObservableObject {
    static let emoji = "👷"

    let fm = FileManager.default
    let db: CopyDB
    var running = false
    let verbose: Bool

    init(db: CopyDB, verbose: Bool = true) {
        self.verbose = verbose

        if verbose {
            os_log("\(Self.i)")
        }

        self.db = db
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

        if verbose {
            os_log("\(self.t)🛫🛫🛫 Run")
        }

        Task {
            let tasks = await self.db.allCopyTasks()

            if tasks.isEmpty {
                self.running = false

                if verbose {
                    os_log("\(self.t)🎉🎉🎉 Done")
                }

                return
            }

            await withTaskGroup(of: Void.self) { group in
                for task in tasks {
                    group.addTask {
                        do {
                            let url = task.url
                            let destination = task.destination.appendingPathComponent(url.lastPathComponent)

                            if self.verbose {
                                os_log("\(self.t)🍋🍋🍋 Copying iCloud file -> \(url.lastPathComponent)")
                            }

                            try await url.copyTo(destination, caller: self.className)

                            if self.verbose {
                                os_log("\(self.t)🎉🎉🎉 Successfully copied iCloud file -> \(url.lastPathComponent)")
                            }

                            await self.db.deleteCopyTasks([url])
                        } catch let e {
                            await self.db.setTaskError(task, e)
                        }
                    }
                }
            }

            self.running = false
        }
    }
}
