import Foundation
import OSLog
import SwiftData
import SwiftUI

/// 监听存储Audio文件的目录的变化，同步到数据库
extension DB {
    func startWatch() async {
        disk.onUpdated = { items in
            self.sync(items)
        }

        await disk.watchAudiosFolder()
    }

    func sync(_ collection: MetadataItemCollection, verbose: Bool = true) {
        var message = "\(label)sync with count=\(collection.count) 🪣🪣🪣"

        if let first = collection.first, first.isDownloading == true {
            message += " -> \(first.fileName ?? "-") -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
        }

        if verbose {
            os_log("\(message)")
        }

        // 第一次查到的item，同步到数据库
        if collection.name == .NSMetadataQueryDidFinishGathering {
            if verbose {
                os_log("\(self.label)第一次查到的item，同步到数据库，共 \(collection.count)")
            }
            syncWithMetas(collection.items)
        }

        // 删除需要删除的
        if collection.itemsForDelete.count > 0 {
            syncWithDeletedItems(collection.itemsForDelete)
        }

        // 将更新的同步到数据库
        if collection.itemsForUpdate.count > 0 {
            syncWithUpdatedItems(collection.itemsForUpdate)
        }

        Task.detached {
            self.updateGroupForMetas(collection.items)
        }
    }

    // MARK: SyncWithMetas

    /// 将数据库和metas同步
    func syncWithMetas(_ metas: [MetaWrapper]) {
        let startTime: DispatchTime = .now()

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

        jobEnd(startTime, title: "syncWithMetas, count=\(metas.count)", tolerance: 0.01)
    }

    // MARK: SyncWithDeletedItems

    func syncWithDeletedItems(_ metas: [MetaWrapper]) {
        printRunTime("SyncWithDeletedItems, count=\(metas.count) 🗑️🗑️🗑️") {
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

        printRunTime("SyncWithUpdatedItems with count=\(metas.count)") {
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
    }.modelContainer(AppConfig.getContainer)
}
