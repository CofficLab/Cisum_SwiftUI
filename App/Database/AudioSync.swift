import Foundation
import SwiftData
import OSLog
import SwiftUI

/// 监听存储Audio文件的目录的变化，同步到数据库
extension DB {
    var eventManager: EventManager {
        EventManager()
    }
    
    func sync(_ items: [MetaWrapper]) {
        Task.detached(priority: .background, operation: {
            var message = "\(Logger.isMain)\(DB.label)sync with count=\(items.count)"
            
            if let first = items.first, first.isDownloading == true {
                message += " -> \(first.fileName ?? "-") -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
            }
            
            os_log("\(message)")
                
            let itemsForSync = items.filter { $0.isUpdated == false }
            let itemsForUpdate = items.filter { $0.isUpdated && $0.isDeleted == false }
            let itemsForDelete = items.filter { $0.isDeleted }
                
            // items.isEmpty 说明本来就是空的，需要将数据库全部删除
            if itemsForSync.isEmpty == false || items.isEmpty {
                // 第一次查到的item，同步到数据库
                self.deleteExcept(itemsForSync.map { $0.url! })
                self.insertAudios(itemsForSync.map { Audio($0) })
            }
            
            // 删除需要删除的
            await self.deleteAudios(itemsForDelete.map { $0.url! })
                
            // 更新查到的item，发出更新事件让UI更新
            await self.eventManager.emitUpdate(itemsForUpdate)
                
            // 如有必要，将更新的插入数据库
            self.insertAudios(itemsForUpdate.map { Audio($0) })
        })
    }
    
    func syncWithUrls(_ urls: [URL]) {
        os_log("\(Logger.isMain)\(Self.label)syncWithUrls, count=\(urls.count)")

        var items = urls
        do {
            try context.enumerate(FetchDescriptor<Audio>(), block: { audio in
                if items.contains(audio.url) == false {
                    // 如果数据库记录不存在items中，数据库删除
                    context.delete(audio)
                } else {
                    // 如果数据库记录存在items中，同步完成
                    items.removeAll(where: { $0 == audio.url })
                }
            })
            
            // 余下的是需要插入数据库的
            items.forEach({
                self.insertAudioIfNotExists(Audio($0))
            })
            
            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
