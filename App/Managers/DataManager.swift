import OSLog
import SwiftData
import SwiftUI

class DataManager: ObservableObject {
    static var label = "💼 DataManager::"

    @Published var appScene: DiskScene
    @Published var disk: any Disk
    @Published var updating: DiskFileGroup = .empty

    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isiCloudDisk: Bool { (disk as? DiskiCloud) != nil }
    var db: DB = DB(Config.getContainer, reason: "dataManager")

    init() throws {
        let verbose = true
        let appScene = Config.getCurrentScene()
        var disk: Disk? = nil
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

    func changeDisk(_ to: Disk) {
        os_log("\(self.label)更新磁盘为 \(to.name)")
        
        self.disk.stopWatch()
        
        disk = to
        
        // 目前，只有Music模式需要监听文件变动并写入数据库
        if self.appScene == .Music {
            watchDisk()
        }
    }

    /// 监听存储Audio文件的目录的变化，同步到数据库
    func watchDisk() {
        disk.onUpdated = { items in
            DispatchQueue.main.async {
                self.updating = items
            }
            
            Task {
                await DB(Config.getContainer, reason: "DataManager.WatchDisk").sync(items)
            }
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
    
    func getChildren(_ asset: PlayAsset, _ callback: @escaping ([PlayAsset]) -> Void) {
        Task {
            let assets = await db.getChildren(Audio(asset.url)).map({
                $0.toPlayAsset()
            })
            
            callback(assets)
        }
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
            os_log("\(Self.label)将文件从 LocalDisk 移动到 CloudDisk 🚛🚛🚛")
            moveAudios(localDisk, cloudDisk)
        } else {
            os_log("\(Self.label)将文件从 CloudDisk 移动到 LocalDisk 🚛🚛🚛")
            moveAudios(cloudDisk, localDisk)
        }
    }
    
    func moveAudios(_ from: any Disk, _ to: any Disk, verbose: Bool = true) {
        Task.detached(priority: .low) {
            if verbose {
                os_log("\(Self.label)将文件从 \(from.root.path) 移动到 \(to.root.path)")
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
                    from.moveFile(at: sourceURL, to: destnationURL)
                }
            } catch {
                os_log("Error: \(error)")
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
