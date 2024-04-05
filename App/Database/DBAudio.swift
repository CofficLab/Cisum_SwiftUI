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
    
    /// 查询第一个有效的
    nonisolated func getFirstValid() -> Audio? {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Audio> {
            $0.downloadingPercent == 100
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
    
    nonisolated func isAllInCloud() -> Bool {
        self.getTotal() > 0 && self.getFirstValid() == nil
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
    
    nonisolated func getTotal() -> Int {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Audio> {
            $0.order != -1
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        do {
            let result = try context.fetchCount(descriptor)
            return result
        } catch {
            return 0
        }
    }
    
    nonisolated func get(_ i: Int) -> Audio? {
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<Audio>()
        descriptor.fetchLimit = 1
        descriptor.fetchOffset = i
        descriptor.sortBy.append(.init(\.downloadingPercent, order: .reverse))
        descriptor.sortBy.append(.init(\.order))
        
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
    
    func preOf(_ audio: Audio) -> Audio? {
        os_log("🍋 DBAudio::preOf [\(audio.order)] \(audio.title)")
        let order = audio.order
        var descriptor = FetchDescriptor<Audio>()
        descriptor.sortBy.append(.init(\.order, order: .reverse))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order < order && $0.downloadingPercent == 100
        }
        
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                os_log("🍋 DBAudio::preOf [\(audio.order)] \(audio.title) -> \(first.title)")
                return first
            } else {
                print("not found")
            }
        } catch let e {
            print(e)
        }

        return nil
    }

    func nextOf(_ audio: Audio) -> Audio? {
        os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
        let order = audio.order
        var descriptor = FetchDescriptor<Audio>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order > order && $0.downloadingPercent == 100
        }
        
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> \(first.title)")
                return first
            } else {
                print("not found")
            }
        } catch let e {
            print(e)
        }

        return nil
    }
}

// MARK: 排序

extension DB {
    func sortRandom() {
        let pageSize = 100 // 每页数据条数
        var offset = 0

        do {
            while true {
                var descriptor = FetchDescriptor<Audio>()
                descriptor.sortBy.append(.init(\.title, order: .reverse))
                descriptor.fetchLimit = pageSize
                descriptor.fetchOffset = offset
                let audioArray = try context.fetch(descriptor)
                
                if audioArray.isEmpty {
                    break
                }
                
                for audio in audioArray {
                    audio.order = Int.random(in: 0...500000000)
                }
                
                try context.save()
                
                offset += pageSize
            }
            
            self.onUpdated()
        } catch let e {
            print(e)
        }
    }
    
    func sort() {
        let pageSize = 100 // 每页数据条数
        var offset = 0

        do {
            while true {
                var descriptor = FetchDescriptor<Audio>()
                descriptor.sortBy.append(.init(\.title, order: .forward))
                descriptor.fetchLimit = pageSize
                descriptor.fetchOffset = offset
                let audioArray = try context.fetch(descriptor)
                
                if audioArray.isEmpty {
                    break
                }
                
                for (index, audio) in audioArray.enumerated() {
                    audio.order = offset + index + 1
                }
                
                try context.save()
                
                offset += pageSize
            }
            
            self.onUpdated()
        } catch let e {
            print(e)
        }
    }
}

// MARK: 修改与下载

extension DB {
    func download(_ audio: Audio) {
        Task {
            try? await CloudHandler().download(url: audio.url)
        }
    }
    
    func downloadNext(_ audio: Audio) {
        let count = 5
        var currentIndex = 0
        var currentAudio: Audio = audio
        
        while currentIndex < count {
            currentIndex = currentIndex + 1
            if let next = nextOf(currentAudio) {
                self.download(next)
                currentAudio = next
            }
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
                    // os_log("\(Logger.isMain)🍋 DB::插入")
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
