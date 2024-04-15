import Foundation
import OSLog
import SwiftData
import SwiftUI

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
    func insert(_ audio: Audio) {
        context.insert(audio)
        try? context.save()
    }
    
    func insertIfNotIn(_ urls: [URL]) {
        let dbURLs = self.getAllURLs()
        for url in urls {
            if dbURLs.contains(url) == false {
                context.insert(Audio(url))
            }
        }
        
        self.save()
    }
}

// MARK: 删除

extension DB {
    func deleteIfNotIn(_ urls: [URL]) {
        try? self.context.delete(model: Audio.self, where: #Predicate {
            urls.contains($0.url) == false
        })
            
        self.save()
    }
    
    nonisolated func delete(_ url: URL) {
        os_log("\(Logger.isMain)🗑️ 数据库删除 \(url.lastPathComponent)")
        Task {
            let context = ModelContext(modelContainer)
            guard let audio = await self.find(url) else {
                return os_log("\(Logger.isMain)🗑️ 删除时数据库找不到 \(url.lastPathComponent)")
            }
            
            do {
                try context.delete(model: Audio.self, where: #Predicate<Audio> {
                    $0.url == url
                })
                try context.save()
                os_log("\(Logger.isMain)🗑️ 删除成功 \(audio.title)")
            } catch let e {
                print(e)
            }
        }
    }
    
    nonisolated func delete(_ audio: Audio) {
        os_log("\(Logger.isMain)🗑️ 数据库删除 \(audio.title)")
        let context = ModelContext(modelContainer)
        guard let audio = context.model(for: audio.id) as? Audio else {
            return os_log("\(Logger.isMain)🗑️ 删除时数据库找不到 \(audio.title)")
        }
        
        do {
            context.delete(audio)
            try context.save()
            os_log("\(Logger.isMain)🗑️ 删除成功 \(audio.title)")
        } catch let e {
            print(e)
        }
    }
    
    func trash(_ audio: Audio) {
        let url = audio.url
        let ext = audio.ext
        let fileName = audio.title
        let trashDir = AppConfig.trashDir
        var trashUrl = trashDir.appendingPathComponent(url.lastPathComponent)
        var times = 1
        
        // 回收站已经存在同名文件
        while fileManager.fileExists(atPath: trashUrl.path) {
            trashUrl = trashUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(times)")
                .appendingPathExtension(ext)
            times += 1
        }
        
        Task {
            // 移动到回收站
            if audio.isExists {
                do {
                    try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
                    
                    // 从数据库删除
                    self.delete(audio)
                } catch let e {
                    print(e)
                }
            }
        }
    }

    /// 清空数据库
    func destroy() {
        try? context.delete(model: Audio.self)
        try? context.save()
    }
}

// MARK: 查询

extension DB {
    func refresh(_ audio: Audio) -> Audio {
        if let a = self.find(audio.id) {
            return a
        } else {
            return audio
        }
    }
    
    nonisolated func countOfURL(_ url: URL) -> Int {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Audio> {
            $0.url == url
        }
        let descriptor = FetchDescriptor<Audio>(predicate: predicate)
        do {
            let result = try context.fetchCount(descriptor)
            return result
        } catch let e {
            print(e)
            return 0
        }
    }
    
    func getAudioDir() -> URL {
        self.audiosDir
    }
    
    func getAllURLs() -> [URL] {
        let predicate = #Predicate<Audio> {
            $0.title != ""
        }
        let descriptor = FetchDescriptor<Audio>(predicate: predicate)
        do {
            return try context.fetch(descriptor).map { $0.url }
        } catch let e {
            print(e)
            return []
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
        descriptor.sortBy.append(SortDescriptor(\.order, order: .forward))
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
                os_log("\(Logger.isMain) ⚠️ DBAudio::get not found")
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
        // os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
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
                // os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> \(first.title)")
                return first
            } else {
                // os_log("⚠️ DBAudio::nextOf [\(audio.order)] \(audio.title) not found")
                // 找不到下一个，则返回第一个
                return self.getFirstValid()
            }
        } catch let e {
            print(e)
        }

        return nil
    }
}

// MARK: 排序

extension DB {
    func sortRandom(_ sticky: Audio?) {
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
                    audio.randomOrder()
                }
                
                if let s = sticky {
                    s.order = 0
                }
                
                try context.save()
                
                offset += pageSize
            }
            
            self.onUpdated()
        } catch let e {
            print(e)
        }
    }
    
    func sort(_ sticky: Audio?) {
        let pageSize = 100 // 每页数据条数
        // 前100留给特殊用途
        var offset = 100

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
                    if let s = sticky, s == audio {
                        audio.order = 0
                    } else {
                        audio.order = offset + index + 1
                    }
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
    func increasePlayCount(_ audio: Audio) {
        if let a = self.find(audio.id) {
            a.playCount += 1
            self.save()
        }
    }
    
    func download(_ audio: Audio, reason: String) {
        Task {
            await DBDownloadJob(db: self).run(audio)
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
    
    func like(_ audio: Audio) {
        if let dbAudio = self.find(audio.id) {
            dbAudio.like = true
            self.save()
        }
    }
    
    func dislike(_ audio: Audio) {
        if let dbAudio = self.find(audio.id) {
            dbAudio.like = false
            self.save()
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
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
