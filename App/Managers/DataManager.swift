import OSLog
import SwiftData
import SwiftUI

class DataManager: ObservableObject {
    static var label = "💼 DataManager::"

    @Published var appScene: DiskScene
    @Published var disk: any Disk
    @Published var updating: DiskFileGroup = .empty
    @Published var syncing: Bool = false

    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isiCloudDisk: Bool { (disk as? DiskiCloud) != nil }
    var db: DB = DB(Config.getContainer, reason: "dataManager")

    init() throws {
        let appScene = Config.getCurrentScene()
        var disk: (any Disk)? = nil
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
        self.changeDisk(disk)
    }

    // MARK: Disk

    func changeDisk(_ to: any Disk) {
        os_log("\(self.label)更新磁盘为 \(to.name)")
        
        self.disk.stopWatch()
        self.disk = to
        self.watchDisk()
    }

    /// 监听存储Audio文件的目录的变化，同步到数据库
    func watchDisk() {
        if self.appScene != .Music && !self.isiCloudDisk {
            return
        }
        
        disk.onUpdated = { items in
            if items.isFullLoad {
                DispatchQueue.main.async {
                    self.syncing = false
                }
            }
            
            DispatchQueue.main.async {
                self.updating = items
            }
            
            if self.appScene == .Music {
                Task {
                    await DB(Config.getContainer, reason: "DataManager.WatchDisk").sync(items)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.syncing = true
        }

        Task {
            await disk.watch()
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
            os_log("\(self.label)DownloadNextBatch(\(self.appScene.title))")
        }
        
        if self.appScene == .Music {
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
        os_log("\(self.label)Enable iCloud")
        let disk = DiskiCloud.make(appScene.folderName)
        
        guard let disk = disk else {
            throw SmartError.NoDisk
        }
        
        self.changeDisk(disk)
        self.migrate()
    }
    
    func disableiCloud() throws {
        os_log("\(self.label)Disable iCloud")
        let disk = DiskLocal.make(appScene.folderName)
        
        guard let disk = disk else {
            throw SmartError.NoDisk
        }
        
        self.changeDisk(disk)
        self.migrate()
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

#Preview {
    AppPreview()
        .frame(height: 800)
}
