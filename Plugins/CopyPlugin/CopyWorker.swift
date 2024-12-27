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
        let verbose = true
        
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
                            
                            if verbose {
                                os_log("\(self.t)Copy -> \(url.path(percentEncoded: false)) -> \(destination.path(percentEncoded: false))")
                            }
                            
                            let isICloudFile = (try? url.resourceValues(forKeys: [.isUbiquitousItemKey]).isUbiquitousItem) ?? false
                            if isICloudFile {
                                try await self.copyiCloudFile(url: url, to: destination, verbose: verbose)
                            } else {
                                try self.fm.copyItem(at: url, to: destination)
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
    
    private func copyiCloudFile(url: URL, to destination: URL, verbose: Bool) async throws {
        if verbose {
            os_log("\(self.t)🌩️🌩️🌩️ Copy iCloud file -> \(url.lastPathComponent)")
        }

        try fm.startDownloadingUbiquitousItem(at: url)
        if verbose {
            os_log("\(self.t)📥 Started download request for -> \(url.lastPathComponent)")
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let itemQuery = ItemQuery(queue: queue)
        itemQuery.verbose = verbose
        
        let result = itemQuery.searchMetadataItems(predicates: [
            NSPredicate(format: "%K == %@", NSMetadataItemURLKey, url as NSURL)
        ])
        
        for try await collection in result {
            if let item = collection.first {
                if verbose {
                    os_log("\(self.t)📊 iCloud download \(url.lastPathComponent): \(Int(item.downloadProgress))%")
                }
                
                if item.isDownloaded {
                    if verbose {
                        os_log("\(self.t)✅ Download complete for -> \(url.lastPathComponent)")
                        os_log("\(self.t)📋 Copying file to destination -> \(destination.lastPathComponent)")
                    }
                    itemQuery.stop()
                    try fm.copyItem(at: url, to: destination)
                    if verbose {
                        os_log("\(self.t)🎉 Successfully copied iCloud file -> \(url.lastPathComponent)")
                    }
                    break
                }
            }
        }
    }
}
