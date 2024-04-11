import Foundation
import OSLog
import SwiftUI

actor DBSync {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    var eventManager = EventManager()
    
    init(db: DB) {
        self.db = db
    }
    
    func run(_ items: [MetadataItemWrapper]) {
        let filtered = items.filter { $0.url != nil }
        if filtered.count > 0 {
            self.sync(items)
        }
    }
    
    func sync(_ items: [MetadataItemWrapper]) {
        Task.detached {
            os_log("\(Logger.isMain)🍋 SyncDB::sync with count=\(items.count)")
            
            let itemsForSync = items.filter { $0.isUpdated==false }
            let itemsForUpdate = items.filter { $0.isUpdated }
            let itemsForDelete = items.filter {$0.isDeleted}
            
            // items.isEmpty 说明本来就是空的，需要将数据库全部删除
            if itemsForSync.isEmpty == false || items.isEmpty {
                // 第一次查到的item，同步到数据库
                await self.deleteIfNotIn(itemsForSync)
                await self.insertIfNotIn(itemsForSync)
            }
            
            // 更新查到的item，发出更新事件让UI更新
            await self.eventManager.emitUpdate(itemsForUpdate)
            
            // 如有必要，将更新的插入数据库
            await self.insertIfNotIn(itemsForUpdate)
            
            // 删除需要删除的
            await self.delete(itemsForDelete)
        }
    }
    
    func delete(_ items:[MetadataItemWrapper]) {
        Task {
            items.forEach{
                self.db.delete($0.url!)
            }
        }
    }
    
    func deleteIfNotIn(_ items: [MetadataItemWrapper]) {
        Task {
            os_log("\(Logger.isMain)🍋 SyncDB::deleteIfNotIn with count=\(items.count)")
            await self.db.deleteIfNotIn(items.map { $0.url! })
        }
    }
    
    func insertIfNotIn(_ items: [MetadataItemWrapper]) {
        Task {
            os_log("\(Logger.isMain)🍋 SyncDB::insertIfNotIn with count=\(items.count)")
            if items.isEmpty {
                return
            }
            await self.db.insertIfNotIn(items.map { $0.url! })
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
