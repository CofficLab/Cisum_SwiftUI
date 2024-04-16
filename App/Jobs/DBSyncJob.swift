import Foundation
import OSLog
import SwiftUI

/// 监听存储Audio文件的目录的变化，同步到数据库
class DBSyncJob {
    var db: DB
    var eventManager = EventManager()
    var label = "🧮 DBSyncJob::"
    var queue = DispatchQueue(label: "DBSyncJob")
    
    init(db: DB) {
        self.db = db
    }
    
    /// 入口，用来保证任务在后台运行
    func run() {
        queue.async {
            self.watchAudiosFolder()
        }
    }
    
    /// 监听存储Audio文件的文件夹
    private func watchAudiosFolder() {
        Task {
            os_log("\(Logger.isMain)\(self.label)watchAudiosFolder")

            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            let query = await ItemQuery(queue: queue, url: self.db.getAudioDir())
            let result = query.searchMetadataItems()
            for try await items in result {
                os_log("\(Logger.isMain)\(self.label)getAudios \(items.count)")
                
                let filtered = items.filter { $0.url != nil }
                if filtered.count > 0 {
                    await self.sync(items)
                }
            }
        }
    }
    
    private func sync(_ items: [MetadataItemWrapper]) async {
        os_log("\(Logger.isMain)\(self.label)sync with count=\(items.count)")
            
        let itemsForSync = items.filter { $0.isUpdated == false }
        let itemsForUpdate = items.filter { $0.isUpdated && $0.isDeleted == false }
        let itemsForDelete = items.filter { $0.isDeleted }
            
        // items.isEmpty 说明本来就是空的，需要将数据库全部删除
        if itemsForSync.isEmpty == false || items.isEmpty {
            // 第一次查到的item，同步到数据库
            await self.deleteIfNotIn(itemsForSync)
            await self.insertIfNotIn(itemsForSync)
        }
            
        // 更新查到的item，发出更新事件让UI更新
        self.eventManager.emitUpdate(itemsForUpdate)
            
        // 如有必要，将更新的插入数据库
        await self.insertIfNotIn(itemsForUpdate)
            
        // 删除需要删除的
        self.delete(itemsForDelete)
    }
    
    private func delete(_ items: [MetadataItemWrapper]) {
        for item in items {
            self.db.delete(item.url!)
        }
    }
    
    private func deleteIfNotIn(_ items: [MetadataItemWrapper]) async {
        os_log("\(Logger.isMain)\(self.label)deleteIfNotIn with count=\(items.count)")
        await self.db.deleteIfNotIn(items.map { $0.url! })
    }
    
    private func insertIfNotIn(_ items: [MetadataItemWrapper]) async {
        os_log("\(Logger.isMain)\(self.label)insertIfNotIn with count=\(items.count)")
        if items.isEmpty {
            return
        }
        await self.db.insertIfNotIn(items.map { $0.url! })
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
