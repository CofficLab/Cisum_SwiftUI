#if os(macOS)
import Foundation
import MagicCore
import OSLog

@MainActor
class CopyWorker: SuperLog, SuperThread, ObservableObject {
    nonisolated static let emoji = "👷"

    let fm = FileManager.default
    let db: CopyDB
    var running = false
    let verbose: Bool = false

    init(db: CopyDB, reason: String) {
        if verbose {
            os_log("\(Self.i) 🐛 \(reason)")
        }

        self.db = db
        Task { [weak self] in
            await self?.run(reason: "init")
        }
    }

    func append(tasks: [(bookmark: Data, filename: String)], folder: URL) {
        Task { [weak self] in
            guard let self else { return }
            await db.addCopyTasks(tasks: tasks, folder: folder)
            await self.run(reason: "append")
        }
    }

    func run(reason: String) async {
        if running {
            return
        }

        running = true

        if verbose {
            os_log("\(self.t)🛫 Run 🐛 \(reason)")
        }

        let tasks = await db.allCopyTaskDTOs()

        if tasks.isEmpty {
            self.running = false
            if verbose {
                os_log("\(self.t)🎉 Done")
            }
            return
        }

        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    var stale = false
                    do {
                        // Resolve the bookmark to get a security-scoped URL
                        guard let url = try? URL(resolvingBookmarkData: task.bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale) else {
                            throw NSError(domain: "CopyWorker", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to resolve bookmark"])
                        }

                        // Start accessing the resource
                        guard url.startAccessingSecurityScopedResource() else {
                            throw NSError(domain: "CopyWorker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to start accessing security-scoped resource"])
                        }
                        
                        // Ensure we stop accessing the resource when we're done
                        defer { url.stopAccessingSecurityScopedResource() }

                        let destination = task.destination.appendingPathComponent(task.originalFilename)

                        // 已经存在了，则忽略
                        if destination.isFileExist {
                            if self.verbose {
                                os_log("\(self.t)⏭️ Skipping, file already exists: \(task.originalFilename)")
                            }
                            // Delete the task as it's already completed.
                            await self.db.deleteCopyTasks(bookmarks: [task.bookmark])
                            return // Exit this task
                        }

                        if self.verbose {
                            os_log("\(self.t)🍋 Copying file -> \(task.originalFilename)")
                        }

                        try await url.copyTo(destination, verbose: self.verbose, caller: self.className)

                        if self.verbose {
                            os_log("\(self.t)🎉 Copied file -> \(task.originalFilename)")
                        }

                        await self.db.deleteCopyTasks(bookmarks: [task.bookmark])
                    } catch let e {
                        os_log(.error, "\(self.t)\(e)")
                        await self.db.setTaskError(bookmark: task.bookmark, error: e.localizedDescription)
                    }
                }
            }
        }

        self.running = false
    }
}
#endif
