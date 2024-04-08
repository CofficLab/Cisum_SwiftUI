import Foundation
import OSLog
import SwiftData

// MARK: 初始化

extension DB {
    /// 将数据库内容设置为items
    func setAudios(_ items: [MetadataItemWrapper]) {
        context.autosaveEnabled = false
        do {
            try context.delete(model: Audio.self)
            for item in items {
                let audio = Audio(item.url!)
                audio.isPlaceholder = item.isPlaceholder
                context.insert(audio)
            }
            
            try context.save()
        } catch let e {
            print(e)
        }
    }
}

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
    func trash(_ audio: Audio) {
        let url = audio.url
        let trashUrl = AppConfig.trashDir.appendingPathComponent(url.lastPathComponent)
        Task {
            try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
        }
    }

    /// 清空数据库
    func destroy() {
        self.clearFolderContents(atPath: audiosDir.path)
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
    func emitUpdate(_ items: [MetadataItemWrapper]) {
        NotificationCenter.default.post(
            name: NSNotification.Name("Updated"),
            object: nil,
            userInfo: [
                "items": items
            ]
        )
    }
    
    func getAudioDir() -> URL {
        self.audiosDir
    }
    
    /// 查询数据，当查到或有更新时会调用回调函数
    func getAudios() {
        os_log("\(Logger.isMain)🍋 DB::getAudios")

        Task {
            let query = ItemQuery(queue: OperationQueue(), url: self.getAudioDir())
            for try await items in query.searchMetadataItems() {
                //os_log("\(Logger.isMain)🍋 DB::getAudios \(items.count)")
                self.upsert(items.filter { $0.url != nil })
                self.emitUpdate(items)
            }
        }
    }
    
    /// 查询第一个有效的
    nonisolated func getFirstValid() -> Audio? {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Audio> {
            $0.title != ""
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
    
    func find(_ id: PersistentIdentifier) -> Audio? {
        context.model(for: id) as? Audio
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
    
    static func find(_ container: ModelContainer, _ url: URL) -> Audio? {
        let context = ModelContext(container)
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
    
    /// 查询数据库中的按照order排序的第x个
    nonisolated func get(_ i: Int) -> Audio? {
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<Audio>()
        descriptor.fetchLimit = 1
        descriptor.fetchOffset = i
        // descriptor.sortBy.append(.init(\.downloadingPercent, order: .reverse))
        descriptor.sortBy.append(.init(\.order))
        
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e {
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
            $0.order < order
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
    
    // MARK: 下一个

    nonisolated func nextOf(_ audio: Audio) -> Audio? {
        //os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
        let context = ModelContext(modelContainer)
        let order = audio.order
        let url = audio.url
        var descriptor = FetchDescriptor<Audio>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order >= order && $0.url != url
        }
        
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                //os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> \(first.title)")
                return first
            } else {
                os_log("⚠️ DBAudio::nextOf [\(audio.order)] \(audio.title) not found")
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
                    audio.makeRandomOrder()
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
            
//            self.onUpdated()
        } catch let e {
            print(e)
        }
    }
}

// MARK: 修改与下载

extension DB {
    func prepare() {
        guard let first = get(0) else {
            return
        }
        
        self.downloadNext(first, reason: "DB::prepare")
    }
    
    func download(_ audio: Audio, reason: String) {
        Task {
            // os_log("\(Logger.isMain)⬇️ DB::download \(audio.title) 🐛 \(reason)")
            do {
                try await CloudHandler().download(url: audio.url)
            } catch let e {
                print(e)
            }
        }
    }
    
    func downloadNext(_ audio: Audio, reason: String) {
        let count = 5
        var currentIndex = 0
        var currentAudio: Audio = audio
        
        while currentIndex < count {
            currentIndex = currentIndex + 1
            if let next = nextOf(currentAudio) {
                self.download(next, reason: "downloadNext 🐛 \(reason)")
                currentAudio = next
            }
        }
    }
    
    nonisolated func update(_ audio: Audio) {
        Task.detached {
            os_log("\(Logger.isMain)🍋 DB::update \(audio.title)")
            let context = ModelContext(self.modelContainer)
            context.autosaveEnabled = false
            if var current = Self.find(self.modelContainer, audio.url) {
                if audio.isDeleted {
                    context.delete(current)
                } else {
                    current = audio
                }
            }

            if context.hasChanges {
                os_log("\(Logger.isMain)🍋 DB::update 保存")
                try? context.save()
                await self.onUpdated()
            } else {
                os_log("\(Logger.isMain)🍋 DB::update nothing changed 👌")
            }
        }
    }

    nonisolated func upsert(_ items: [MetadataItemWrapper]) {
        Task.detached {
            os_log("\(Logger.isMain)🍋 DB::upsert with count=\(items.count)")
            let context = ModelContext(self.modelContainer)
            context.autosaveEnabled = false
            for item in items {
                if var current = Self.find(self.modelContainer, item.url!) {
                    if item.isDeleted {
                        context.delete(current)
                        continue
                    }
                    
                    // os_log("\(Logger.isMain)🍋 DB::更新 \(current.title)")
                    current = current.mergeWith(item)
                } else {
                    // os_log("\(Logger.isMain)🍋 DB::插入")
                    if let audio = Audio.fromMetaItem(item) {
                        context.insert(audio)
                    }
                }
            }

            if context.hasChanges {
                os_log("\(Logger.isMain)🍋 DB::保存")
                try? context.save()
//                await self.onUpdated()
            } else {
                os_log("\(Logger.isMain)🍋 DB::upsert nothing changed 👌")
            }
        }
    }
}
