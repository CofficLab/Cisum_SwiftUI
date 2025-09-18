import Foundation
import MagicCore

import OSLog

@MainActor
class CopyWorker: SuperLog, SuperThread, ObservableObject {
    nonisolated static let emoji = "👷"

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
        Task { [weak self] in
            await self?.run()
        }
    }

    func append(_ urls: [URL], folder: URL) {
        Task { [weak self] in
            guard let self else { return }
            for url in urls {
                await db.newCopyTask(url, destination: folder)
            }

            await self.run()
        }
    }

    func run() async {
        if running {
            return
        }

        running = true

        if verbose {
            os_log("\(self.t)🛫🛫🛫 Run")
        }

        let tasks = await db.allCopyTaskDTOs()

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

                        try await url.copyTo(destination, verbose: true, caller: self.className)

                        if self.verbose {
                            os_log("\(self.t)🎉🎉🎉 Successfully copied iCloud file -> \(url.lastPathComponent)")
                        }

                        await self.db.deleteCopyTasks([url])
                    } catch let e {
                        os_log(.error, "\(self.t)\(e)")
                        await self.db.setTaskError(url: task.url, error: e.localizedDescription)
                    }
                }
            }
        }

        self.running = false
    }
}
