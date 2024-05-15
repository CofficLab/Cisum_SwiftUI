import Foundation
import OSLog
import SwiftData
import SwiftUI

/// 监听存储Audio文件的目录的变化，同步到数据库
extension DB {
    var eventManager: EventManager {
        EventManager()
    }
    
    func startWatch() async {
        self.disk.onUpdated = { items in
            self.sync(items)
        }

        await self.disk.watchAudiosFolder()
    }
    
    func sync(_ items: [MetaWrapper], verbose: Bool = false) {
        var message = "\(Logger.isMain)\(DB.label)sync with count=\(items.count) 🪣🪣🪣"
        
        if let first = items.first, first.isDownloading == true {
            message += " -> \(first.fileName ?? "-") -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
        }
        
        if verbose {
            os_log("\(message)")
        }
            
        let itemsForSync = items.filter { $0.isUpdated == false }
        let itemsForUpdate = items.filter { $0.isUpdated && $0.isDeleted == false }
        let itemsForDelete = items.filter { $0.isDeleted }
        
        // 磁盘目录是空的，需要将数据库清空
        if items.isEmpty {
            return self.syncWithEmpty()
        }
        
        // 第一次查到的item，同步到数据库
        if itemsForSync.count > 0 {
            self.syncWithMetas(items)
        }
        
        // 删除需要删除的
        if itemsForDelete.count > 0 {
            self.syncWithDeletedItems(itemsForDelete)
        }
            
        // 将更新的同步到数据库
        if itemsForUpdate.count > 0 {
            self.syncWithUpdatedItems(itemsForUpdate)
        }
    }
    
    // MARK: SyncWithMetas
    
    /// 将数据库和metas同步
    func syncWithMetas(_ metas: [MetaWrapper]) {
        self.printRunTime("syncWithMetas, count=\(metas.count)") {
            let context = ModelContext(modelContainer)
            context.autosaveEnabled = false

            // 将数组转换成哈希表，方便通过键来快速查找元素，这样可以将时间复杂度降低到：O(m+n)
            var hashMap = [URL: MetaWrapper]()
            for element in metas {
                hashMap[element.url!] = element
            }
            
            do {
                try context.enumerate(FetchDescriptor<Audio>(), block: { audio in
                    if hashMap[audio.url] == nil {
                        // 记录不存在哈希表中，数据库删除
                        context.delete(audio)
                    } else {
                        // 记录存在哈希表中，同步完成，删除哈希表记录
                        hashMap.removeValue(forKey: audio.url)
                    }
                })
                
                // 余下的是需要插入数据库的
                for (_, value) in hashMap {
                    context.insert(Audio.fromMetaItem(value)!)
                }
                
                try context.save()
            } catch {
                os_log(.error, "\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: SyncWithEmpty
    
    func syncWithEmpty() {
        do {
            try context.delete(model: Audio.self)
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    // MARK: SyncWithDeletedItems
    
    func syncWithDeletedItems(_ metas: [MetaWrapper]) {
        self.printRunTime("SyncWithDeletedItems, count=\(metas.count) 🗑️🗑️🗑️") {
            let context = ModelContext(modelContainer)
            context.autosaveEnabled = false
            
            do {
                let urls = metas.map({ $0.url! })
                try context.delete(model: Audio.self, where: #Predicate { audio in
                    urls.contains(audio.url)
                })
                
                try context.save()
            } catch {
                os_log(.error, "\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: SyncWithUpdatedItems
    
    func syncWithUpdatedItems(_ metas: [MetaWrapper]) {
        // 发出更新事件让UI更新，比如下载进度
        Task {
            self.eventManager.emitUpdate(metas)
        }
        
        self.printRunTime("SyncWithUpdatedItems with count=\(metas.count)") {
            let context = ModelContext(self.modelContainer)
            context.autosaveEnabled = false
            
            // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
            // 但在这里，希望如果存在，就不要插入
            for (_, meta) in metas.enumerated() {
                if Self.findAudio(context: context, meta.url!) == nil {
                    context.insert(Audio.fromMetaItem(meta)!)
                }
            }
            
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
