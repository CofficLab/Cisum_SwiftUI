import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    /// 往数据库添加文件
    func add(
        _ urls: [URL],
        completionAll: @escaping () -> Void,
        completionOne: @escaping (_ sourceUrl: URL) -> Void,
        onStart: @escaping (_ audio: Audio) -> Void
    ) {
        for url in urls {
            onStart(Audio(url))
            SmartFile(url: url).copyTo(
                destnation: audiosDir.appendingPathComponent(url.lastPathComponent))
            completionOne(url)
        }

        completionAll()
    }
}

// MARK: 删除

extension DB {
    func delete(_ audio: Audio) {
        let url = audio.url
        let trashUrl = AppConfig.trashDir.appendingPathComponent(url.lastPathComponent)

        Task {
            try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
        }
    }

    /// 清空数据库
    func destroy() {
        clearFolderContents(atPath: audiosDir.path)
    }

    func clearFolderContents(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = URL(fileURLWithPath: path).appendingPathComponent(item).path
                try fileManager.removeItem(atPath: itemPath)
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: 查询

extension DB {
    /// 查询数据，当查到或有更新时会调用回调函数
    func getAudios() {
        os_log("\(Logger.isMain)🍋 DB::getAudios")
        let query = ItemQuery(queue: OperationQueue(), url: audiosDir)
        Task {
            for try await items in query.searchMetadataItems() {
                Task.detached {
                    os_log("\(Logger.isMain)🍋 DB::getAudios \(items.count)")
                    self.upsert(items.filter { $0.url != nil })
                }
            }
        }
    }

    func find(_ url: URL) -> Audio? {
        let predicate = #Predicate<Audio> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<Audio>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            print(e)
        }

        return nil
    }

    static func find(_ context: ModelContext, _ url: URL) -> Audio? {
        let predicate = #Predicate<Audio> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<Audio>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            print(e)
        }

        return nil
    }
}

// MARK: 修改

extension DB {
    func download(_ url: URL) {
        Task {
            try? await CloudHandler().download(url: url)
        }
    }

    nonisolated func upsert(_ items: [MetadataItemWrapper]) {
        Task.detached {
            os_log("\(Logger.isMain)🍋 DB::upsert with count=\(items.count)")
            let context = ModelContext(self.modelContainer)
            context.autosaveEnabled = false
            for item in items {
                if let current = Self.find(context, item.url!) {
                    var updated: String = ""
                    if current.isDownloading != item.isDownloading {
                        updated += "🐛isDownloading[\(current.isDownloading)->\(item.isDownloading)]"
                        current.isDownloading = item.isDownloading
                    }

                    if current.downloadingPercent != item.downloadProgress {
                        updated += "🐛downloadingPercent[\(current.downloadingPercent)->\(item.downloadProgress)]"
                        current.downloadingPercent = item.downloadProgress
                    }

                    if updated.count > 0 {
                        os_log("\(Logger.isMain)🍋 DB::更新 \(current.title) \(updated)")
                    }
                } else {
                    //os_log("\(Logger.isMain)🍋 DB::插入")
                    let audio = Audio(item.url!)
                    audio.isDownloading = item.isDownloading
                    audio.downloadingPercent = item.downloadProgress
                    audio.isPlaceholder = item.isPlaceholder
                    context.insert(audio)
                }
            }

            if context.hasChanges {
                os_log("\(Logger.isMain)🍋 DB::保存")
                try? context.save()
                await self.onUpdated()
            }
        }
    }
}
