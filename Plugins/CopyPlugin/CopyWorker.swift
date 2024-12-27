import Foundation
import MagicKit
import OSLog

class CopyWorker: SuperLog, SuperThread, ObservableObject {
    static let emoji = "👷"

    let fm = FileManager.default
    let db: CopyDB
    var running = false

    init(db: CopyDB, verbose: Bool = false) {
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
        let verbose = false

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

                            try await url.copyTo(destination) { progress in
                                if verbose {
                                    os_log("\(self.t)📊 iCloud download \(url.lastPathComponent): \(Int(progress))%")
                                }
                            }

                            if verbose {
                                os_log("\(self.t)🎉 Successfully copied iCloud file -> \(url.lastPathComponent)")
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
