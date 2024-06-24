import SwiftUI
import OSLog
import SwiftData

class DiskManager: ObservableObject {
    static var label = "💼 DiskManager::"
    
    @Published var appScene: AppScene
    @Published var disk: any Disk
    
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isiCloudDisk: Bool { ((self.disk as? DiskiCloud) != nil)}
    var db: DB = DB(Config.getContainer, reason: "DiskManager")
    
    init() {
        let verbose = true
        let appScene = Config.getCurrentScene()
        self.appScene = appScene
        
        if Config.iCloudEnabled {
            self.disk = DiskiCloud.makeSub(appScene.folderName)
        } else {
            self.disk = DiskLocal.makeSub(appScene.folderName)
        }
        
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化，iCloud=\(Config.iCloudEnabled)")
            os_log("\(Logger.isMain)\(Self.label)初始化，Disk=\(self.disk.name)")
        }
        
        Task {
            /// 监听存储Audio文件的目录的变化，同步到数据库
            disk.onUpdated = { items in
                Task {
                    await self.db.sync(items)
                }
            }

            await disk.watchAudiosFolder()
        }
    }
    
    func changeDisk(_ to: Disk) {
        os_log("\(self.label)更新磁盘为 \(to.name)")
        self.disk = to
    }
    
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
    
    func chageScene(_ to: AppScene) {
        self.appScene = to
        self.changeDisk(self.disk.makeSub(to.folderName))
        
        Config.setCurrentScene(to)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
