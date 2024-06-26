import OSLog
import SwiftData
import SwiftUI

class DataManager: ObservableObject {
    static var label = "💼 dataManager::"

    @Published var appScene: DiskScene
    @Published var disk: any Disk
    @Published var updating: DiskFileGroup = .empty

    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isiCloudDisk: Bool { (disk as? DiskiCloud) != nil }
    var db: DB = DB(Config.getContainer, reason: "dataManager")

    init() {
        let verbose = true
        let appScene = Config.getCurrentScene()
        self.appScene = appScene

        if Config.iCloudEnabled {
            disk = DiskiCloud.makeSub(appScene.folderName)
        } else {
            disk = DiskLocal.makeSub(appScene.folderName)
        }

        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化(\(self.disk.name))")
        }

        Task {
            self.watchDisk()
        }
    }

    // MARK: Disk

    func changeDisk(_ to: Disk) {
        os_log("\(self.label)更新磁盘为 \(to.name)")
        disk = to
        watchDisk()
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

    func chageScene(_ to: DiskScene) {
        appScene = to
        changeDisk(disk.makeSub(to.folderName))

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

#Preview {
    AppPreview()
        .frame(height: 800)
}
