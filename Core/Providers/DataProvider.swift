import OSLog
import SwiftData
import SwiftUI

class DataProvider: ObservableObject, SuperLog {
    static var label = "💼 DataManager::"

    @Published var disk: any Disk
    @Published var syncing: Bool = false

    let emoji = "💼"
    var isiCloudDisk: Bool { (disk as? DiskiCloud) != nil }
    var isNotiCloudDisk: Bool { !isiCloudDisk }
    var db: DB = DB(Config.getContainer, reason: "dataManager")

    init() throws {
        var disk: (any Disk)?

        if Config.iCloudEnabled {
            disk = DiskiCloud.make("audios")
        } else {
            disk = DiskLocal.make("audios")
        }

        guard let disk = disk else {
            throw SmartError.NoDisk
        }

        self.disk = disk
    }


    // MARK: Copy

    func deleteCopyTask(_ task: CopyTask) {
        Task {
            await db.deleteCopyTask(task.id)
        }
    }

    func copy(_ urls: [URL]) {
        Task {
            await self.db.addCopyTasks(urls)
        }
    }
}

// MARK: Download

extension DataProvider {
    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String, verbose: Bool = false) {
//        if verbose {
//            os_log("\(self.t)DownloadNextBatch(\(self.appScene.title))")
//        }

//        if appScene == .Music {
//            Task {
//                var currentIndex = 0
//                var currentURL: URL = url
//
//                while currentIndex < count {
//                    disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")
//
//                    currentIndex = currentIndex + 1
//
//                    if let next = await db.nextOf(currentURL) {
//                        currentURL = next.url
//                    } else {
//                        break
//                    }
//                }
//            }
//        } else {
//            var currentIndex = 0
//            var currentURL: URL = url
//
//            while currentIndex < count {
//                disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")
//
//                currentIndex = currentIndex + 1
//
//                if let next = disk.next(currentURL) {
//                    currentURL = next.url
//                } else {
//                    break
//                }
//            }
//        }
    }
}

// MARK: Migrate

extension DataProvider {
    func enableiCloud() throws {
        os_log("\(self.t)Enable iCloud")
        let disk = DiskiCloud.make("audios")

        guard disk != nil else {
            throw SmartError.NoDisk
        }

        migrate()
    }

    func disableiCloud() throws {
        os_log("\(self.t)Disable iCloud")
        let disk = DiskLocal.make("audios")

        guard disk != nil else {
            throw SmartError.NoDisk
        }

        migrate()
    }

    func migrate() {
        guard let localMountedURL = DiskLocal.getMountedURL() else {
            return
        }

        guard let cloudMoutedURL = DiskiCloud.getMountedURL() else {
            return
        }

        let localDisk = DiskLocal(root: localMountedURL)
        let cloudDisk = DiskiCloud(root: cloudMoutedURL)

        if Config.iCloudEnabled {
            moveAudios(localDisk, cloudDisk)
        } else {
            moveAudios(cloudDisk, localDisk)
        }
    }

    func moveAudios(_ from: any Disk, _ to: any Disk, verbose: Bool = true) {
        Task.detached(priority: .low) {
            if verbose {
                os_log("\(Self.label)将文件从 \(from.name) 移动到 \(to.name)")
            }

            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: from.root.path).filter({
                    !$0.hasSuffix(".DS_Store")
                })

                for file in files {
                    let sourceURL = URL(fileURLWithPath: from.root.path).appendingPathComponent(file)
                    let destnationURL = to.makeURL(file)

                    if verbose {
                        os_log("\(Self.label)移动 \(sourceURL.lastPathComponent)")
                    }
                    await from.moveFile(at: sourceURL, to: destnationURL)
                }
            } catch {
                os_log("Error: \(error)")
            }

            if verbose {
                os_log("\(Self.label)将文件从 \(from.name) 移动到 \(to.name) 完成 🎉🎉🎉")
            }
        }
    }
}

// MARK: FirstPlayAsset

extension DataProvider {
    func first() -> PlayAsset? {
            db.firstAudio()?.toPlayAsset()
//            disk.getRoot().children?.first?.toPlayAsset()
    }
}

// MARK: Book

extension DataProvider {
    func findBookState(_ book: Book, verbose: Bool = false) -> BookState? {
        if verbose {
            os_log("\(self.t)FindState for \(book.title)")
        }

        let db = DBSynced(Config.getSyncedContainer)

        if let state = db.findOrInsertBookState(book.url) {
            return state
        } else {
            if verbose {
                os_log("\(self.t)\(book.title) 无上次播放")
            }

            return nil
        }
    }

    func updateBookState(_ bookURL: URL, _ current: URL, verbose: Bool = true) {
        if verbose {
            os_log("\(self.t)FindState for \(bookURL.lastPathComponent)")
        }

        Task {
            let db = DBSynced(Config.getSyncedContainer)
            await db.updateBookCurrent(bookURL, currentURL: current)
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
