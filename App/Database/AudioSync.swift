import Foundation
import OSLog
import SwiftUI

/// 监听存储Audio文件的目录的变化，同步到数据库
extension DB {
    var eventManager: EventManager {
        EventManager()
    }
    
    func sync(_ items: [MetadataItemWrapper]) async {
        //os_log("\(Logger.isMain)\(self.label)sync with count=\(items.count)")
            
        let itemsForSync = items.filter { $0.isUpdated == false }
        let itemsForUpdate = items.filter { $0.isUpdated && $0.isDeleted == false }
        let itemsForDelete = items.filter { $0.isDeleted }
            
        // items.isEmpty 说明本来就是空的，需要将数据库全部删除
        if itemsForSync.isEmpty == false || items.isEmpty {
            // 第一次查到的item，同步到数据库
            await self.deleteIfNotIn(itemsForSync)
            await self.insertIfNotIn(itemsForSync)
        }
        
        // 删除需要删除的
        self.delete(itemsForDelete)
        
        // 删除无效的，必须放在处理Duplicate逻辑前
        await deleteInvalid()
            
        // 更新查到的item，发出更新事件让UI更新
        self.eventManager.emitUpdate(itemsForUpdate)
            
        // 如有必要，将更新的插入数据库
        await self.insertIfNotIn(itemsForUpdate)
        
        // 处理Duplicate逻辑
        await findDuplicatesJob()
    }
    
    private func delete(_ items: [MetadataItemWrapper]) {
        //os_log("\(Logger.isMain)\(self.label)delete with count=\(items.count)")
        
        for item in items {
            Task {
                self.deleteAudio(item.url!)
                
                // 发出事件让UI更新
                self.eventManager.emitDelete(items)
            }
        }
    }
    
    private func deleteIfNotIn(_ items: [MetadataItemWrapper]) async {
        //os_log("\(Logger.isMain)\(self.label)deleteIfNotIn with count=\(items.count)")
        self.deleteIfNotIn(items.map { $0.url! })
    }
    
    private func insertIfNotIn(_ items: [MetadataItemWrapper]) async {
        if verbose {
            os_log("\(self.label)insertIfNotIn with count=\(items.count)")
        }
        
        if items.isEmpty {
            return
        }
        
        self.insertIfNotIn(items.map { $0.url! })
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
