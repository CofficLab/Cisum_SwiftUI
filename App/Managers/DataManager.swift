import OSLog
import SwiftData
import SwiftUI

class DataManager: ObservableObject, SuperLog {
    static var label = "💼 DataManager::"

    @Published var appScene: DiskScene
    @Published var disk: any Disk
    @Published var updating: DiskFileGroup = .empty
    @Published var syncing: Bool = false

    let emoji = "💼"
    var isiCloudDisk: Bool { (disk as? DiskiCloud) != nil }
    var isNotiCloudDisk: Bool { !isiCloudDisk }
    var db: DB = DB(Config.getContainer, reason: "dataManager")

    init() throws {
        let appScene = Config.getCurrentScene()
        var disk: (any Disk)?
        self.appScene = appScene

        if Config.iCloudEnabled {
            disk = DiskiCloud.make(appScene.folderName)
        } else {
            disk = DiskLocal.make(appScene.folderName)
        }

        guard let disk = disk else {
            throw SmartError.NoDisk
        }

        self.disk = disk
        changeDisk(disk)
    }

    // MARK: ChangeDisk

    func changeDisk(_ to: any Disk) {
        os_log("\(self.t)更新磁盘为 \(to.name)")

        disk.stopWatch(reason: "Disk Will Change")
        disk = to
        watchDisk(reason: "Disk Changed")
    }

    // MARK: WatchDisk

    func watchDisk(reason: String) {
        disk.onUpdated = { items in
            if items.isFullLoad {
                DispatchQueue.main.async {
                    self.syncing = false
                }
            }

            DispatchQueue.main.async {
                self.updating = items
            }

            switch self.appScene {
            case .Music:
                Task {
                    await DB(Config.getContainer, reason: "DataManager.WatchDisk").sync(items)
                }
            case .AudiosBook:
                Task {
                    await DB(Config.getContainer, reason: "DataManager.WatchDisk").bookSync(items)
                }
            case .AudiosKids, .Videos, .VideosKids:
                break
            }
        }

        DispatchQueue.main.async {
            self.syncing = true
        }

        Task {
            await disk.watch(reason: reason)
        }
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

    func copyFiles() {
        Task.detached(priority: .low) {
            let tasks = await self.db.allCopyTasks()

            for task in tasks {
                Task {
                    do {
                        let url = task.url
                        try self.disk.copyTo(url: url)
                        await self.db.deleteCopyTasks([url])
                    } catch let e {
                        await self.db.setTaskError(task, e)
                    }
                }
            }
        }
    }

    // MARK: Scene

    func chageScene(_ to: DiskScene) throws {
        appScene = to

        guard let disk = disk.make(to.folderName) else {
            throw SmartError.NoDisk
        }

        changeDisk(disk)
        Config.setCurrentScene(to)
    }
}

// MARK: Download

extension DataManager {
    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)DownloadNextBatch(\(self.appScene.title))")
        }

        if appScene == .Music {
            Task {
                var currentIndex = 0
                var currentURL: URL = url

                while currentIndex < count {
                    disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")

                    currentIndex = currentIndex + 1

                    if let next = await db.nextOf(currentURL) {
                        currentURL = next.url
                    } else {
                        break
                    }
                }
            }
        } else {
            var currentIndex = 0
            var currentURL: URL = url

            while currentIndex < count {
                disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")

                currentIndex = currentIndex + 1

                if let next = disk.next(currentURL) {
                    currentURL = next.url
                } else {
                    break
                }
            }
        }
    }
}

// MARK: Migrate

extension DataManager {
    func enableiCloud() throws {
        os_log("\(self.t)Enable iCloud")
        let disk = DiskiCloud.make(appScene.folderName)

        guard let disk = disk else {
            throw SmartError.NoDisk
        }

        changeDisk(disk)
        migrate()
    }

    func disableiCloud() throws {
        os_log("\(self.t)Disable iCloud")
        let disk = DiskLocal.make(appScene.folderName)

        guard let disk = disk else {
            throw SmartError.NoDisk
        }

        changeDisk(disk)
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

extension DataManager {
    func first() -> PlayAsset? {
        switch appScene {
        case .Music:
            db.firstAudio()?.toPlayAsset()
        default:
            disk.getRoot().children?.first?.toPlayAsset()
        }
    }
}

// MARK: Book

extension DataManager {
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
