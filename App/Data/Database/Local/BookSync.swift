import Foundation
import OSLog
import SwiftData
import SwiftUI

extension DB {
    var labelForBookSync: String {
        "\(label)📖📖📖"
    }

    func bookSync(_ group: DiskFileGroup, verbose: Bool = true) {
        var message = "\(labelForBookSync) Sync(\(group.count))"

        if let first = group.first, first.isDownloading == true {
            message += " -> \(first.fileName) -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
        }
        
        if group.isFullLoad {
            message += " Full"
        } else {
            message += " Update"
        }

        if verbose {
            os_log("\(message)")
        }

        if group.isFullLoad {
            bookSyncWithDisk(group)
        } else {
            bookSyncWithUpdatedItems(group)
        }

//        if verbose {
//            os_log("\(self.labelForSync) 计算刚刚同步的项目的 Hash(\(group.count))")
//        }
//
//        self.updateGroupForURLs(group.urls)
    }

    // MARK: SyncWithDisk

    func bookSyncWithDisk(_ group: DiskFileGroup) {
        let verbose = true
        let startTime: DispatchTime = .now()

        // 将数组转换成哈希表，方便通过键来快速查找元素，这样可以将时间复杂度降低到：O(m+n)
        var hashMap = group.hashMap

        do {
            try context.enumerate(FetchDescriptor<Book>(), block: { book in
                if let item = hashMap[book.url] {
                    // 更新数据库记录
                    book.isCollection = item.isFolder
                    book.bookTitle = book.title
                    
                    // 记录存在哈希表中，同步完成，删除哈希表记录
                    hashMap.removeValue(forKey: book.url)
                } else {
                    // 记录不存在哈希表中，数据库删除
                    if verbose {
                        os_log("\(self.labelForBookSync) 删除 \(book.title)")
                    }
                    context.delete(book)
                }
            })

            // 余下的是需要插入数据库的
            for (_, value) in hashMap {
                context.insert(value.toBook())
            }
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }
        
        do {
            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }

        os_log("\(self.jobEnd(startTime, title: "\(self.labelForSync) SyncWithDisk(\(group.count))", tolerance: 0.01))")
        
        self.updateBookParent()
    }

    // MARK: SyncWithUpdatedItems

    func bookSyncWithUpdatedItems(_ metas: DiskFileGroup, verbose: Bool = false) {
        if verbose {
            os_log("\(self.label)SyncWithUpdatedItems with count=\(metas.count)")
        }
        
        // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
        // 但在这里，希望如果存在，就不要插入
        for (_, meta) in metas.files.enumerated() {
            if meta.isDeleted {
                let deletedURL = meta.url

                do {
                    try context.delete(model: Book.self, where: #Predicate { book in
                        book.url == deletedURL
                    })
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            } else {
                if findBook(meta.url) == nil {
                    context.insert(meta.toBook())
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
