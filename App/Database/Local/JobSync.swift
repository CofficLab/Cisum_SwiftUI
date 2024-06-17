import Foundation
import OSLog
import SwiftData
import SwiftUI

extension DB {
    // MARK: Watch
    
    /// 监听存储Audio文件的目录的变化，同步到数据库
    func startWatch() async {
        disk.onUpdated = { items in
            self.sync(items)
        }

        await disk.watchAudiosFolder()
    }

    func sync(_ collection: DiskFileGroup, verbose: Bool = true) {
        var message = "\(label)sync with count=\(collection.count) 🪣🪣🪣"

        if let first = collection.first, first.isDownloading == true {
            message += " -> \(first.fileName) -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
        }

        if verbose {
            os_log("\(message)")
        }

        // 全量，同步到数据库
        if collection.isFullLoad {
            if verbose {
                os_log("\(self.label)全量同步，共 \(collection.count)")
            }
            
            syncWithMetas(collection)
        } else {
            if verbose {
                os_log("\(self.label)部分同步，共 \(collection.count)")
            }
            
            syncWithUpdatedItems(collection)
        }

        Task.detached {
            self.updateGroupForMetas(collection)
        }
    }

    // MARK: SyncWithMetas

    /// 将数据库和metas同步
    func syncWithMetas(_ metas: DiskFileGroup) {
        let startTime: DispatchTime = .now()

        // 将数组转换成哈希表，方便通过键来快速查找元素，这样可以将时间复杂度降低到：O(m+n)
        var hashMap = metas.hashMap

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
                context.insert(value.toAudio())
            }

            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }

        jobEnd(startTime, title: "syncWithMetas, count=\(metas.count)", tolerance: 0.01)
    }
    
    // MARK: SyncWithUpdatedItems

    func syncWithUpdatedItems(_ metas: DiskFileGroup) {
        // 发出更新事件让UI更新，比如下载进度
        Task {
//            self.eventManager.emitUpdate(metas)
        }

        printRunTime("SyncWithUpdatedItems with count=\(metas.count)") {
            // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
            // 但在这里，希望如果存在，就不要插入
            for (_, meta) in metas.files.enumerated() {
                if meta.isDeleted {
                    let deletedURL = meta.url
                    
                    do {
                        try context.delete(model: Audio.self, where: #Predicate { audio in
                            audio.url == deletedURL
                        })
                    } catch let e {
                        os_log(.error, "\(e.localizedDescription)")
                    }
                } else {
                    if Self.findAudio(context: context, meta.url) == nil {
                        context.insert(meta.toAudio())
                    }
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
