import Foundation
import OSLog
import SwiftData
import SwiftUI

extension DB {
    // MARK: Watch

    var labelForSync: String {
        "\(label)🪣🪣🪣"
    }

    func sync(_ group: DiskFileGroup, verbose: Bool = true) {
        var message = "\(labelForSync) Sync(\(group.count))"

        if let first = group.first, first.isDownloading == true {
            message += " -> \(first.fileName) -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
        }

        if verbose {
            os_log("\(message)")
        }

        if group.isFullLoad {
            syncWithDisk(group)
        } else {
            syncWithUpdatedItems(group)
        }

//        if verbose {
//            os_log("\(self.labelForSync) 计算刚刚同步的项目的 Hash(\(group.count))")
//        }
//
//        self.updateGroupForURLs(group.urls)
    }

    // MARK: SyncWithDisk

    func syncWithDisk(_ group: DiskFileGroup) {
        let verbose = false
        let startTime: DispatchTime = .now()

        // 将数组转换成哈希表，方便通过键来快速查找元素，这样可以将时间复杂度降低到：O(m+n)
        var hashMap = group.hashMap

        do {
            try context.enumerate(FetchDescriptor<Audio>(), block: { audio in
                if let item = hashMap[audio.url] {
                    // 更新数据库记录
                    audio.size = item.size

                    // 记录存在哈希表中，同步完成，删除哈希表记录
                    hashMap.removeValue(forKey: audio.url)
                } else {
                    // 记录不存在哈希表中，数据库删除
                    if verbose {
                        os_log("\(self.label)删除 \(audio.title)")
                    }
                    context.delete(audio)
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

        os_log("\(self.jobEnd(startTime, title: "\(self.labelForSync) SyncWithDisk(\(group.count))", tolerance: 0.01))")
    }

    // MARK: SyncWithUpdatedItems

    func syncWithUpdatedItems(_ metas: DiskFileGroup, verbose: Bool = true) {
        os_log("\(self.label)SyncWithUpdatedItems with count=\(metas.count)")
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
                if findAudio(meta.url) == nil {
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

#Preview {
    BootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
