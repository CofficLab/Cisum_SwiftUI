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
        self.save()

        updateDuplicatedOf(audio)
    }

    func insertIfNotIn(_ urls: [URL]) {
        let dbURLs = getAllURLs()
        for url in urls {
            if dbURLs.contains(url) == false {
                insert(Audio(url))
            }
        }
    }
}

// MARK: 删除

extension DB {
    func deleteIfNotIn(_ urls: [URL]) {
        try? context.delete(model: Audio.self, where: #Predicate {
            urls.contains($0.url) == false
        })

        save()
    }

    nonisolated func delete(_ url: URL) {
        os_log("\(Logger.isMain)\(DB.label)数据库删除 \(url.lastPathComponent)")
        Task {
            let context = ModelContext(modelContainer)
            guard (await self.find(url)) != nil else {
                return os_log("\(Logger.isMain)\(DB.label)删除时数据库找不到 \(url.lastPathComponent)")
            }

            do {
                // set duplicatedOf to nil
                try context.fetch(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.duplicatedOf == url
                })).forEach({
                    $0.duplicatedOf = nil
                })
                
                // delete
                try context.delete(model: Audio.self, where: #Predicate<Audio> {
                    $0.url == url
                })
                try context.save()
            } catch let e {
                print(e)
            }
        }
    }

    nonisolated func delete(_ audios: [Audio]) {
        for audio in audios {
            delete(audio)
        }
    }

    func delete(_ audios: [Audio.ID]) -> Audio? {
        var next: Audio?

        for audio in audios {
            next = delete(audio)
        }

        return next
    }

    func delete(_ id: Audio.ID) -> Audio? {
        os_log("\(Logger.isMain)\(DB.label)数据库删除")
        let context = ModelContext(modelContainer)
        guard let audio = context.model(for: id) as? Audio else {
            os_log("\(Logger.isMain)\(DB.label)删除时数据库找不到")
            return nil
        }

        // 找出下一个
        var next = nextOf(audio)
        if next?.url == audio.url {
            os_log("\(Logger.isMain)\(DB.label)删除时next==current")
            next = nil
        }

        do {
            // 从磁盘删除
            try dbFolder.deleteFile(audio)

            // 从磁盘删除后，因为数据库监听了磁盘的变动，会自动删除
            // 但自动删除可能不及时，所以这里及时删除
            context.delete(audio)

            try context.save()
            os_log("\(Logger.isMain)\(DB.label)删除成功 \(audio.title)")
        } catch let e {
            os_log("\(Logger.isMain)\(DB.label)删除出错 \(e)")
        }

        return next
    }

    nonisolated func delete(_ audio: Audio) {
        os_log("\(Logger.isMain)\(DB.label)数据库删除 \(audio.title)")
        let context = ModelContext(modelContainer)
        guard let audio = context.model(for: audio.id) as? Audio else {
            return os_log("\(Logger.isMain)\(DB.label)删除时数据库找不到 \(audio.title)")
        }

        do {
            context.delete(audio)
            try context.save()
        } catch let e {
            os_log("\(Logger.isMain)\(DB.label)删除出错 \(e.localizedDescription)")
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
                    os_log("\(Logger.isMain)\(DB.label)回收站出错 \(e.localizedDescription)")
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

// MARK: 查询-Duplicate

extension DB {
    func findDuplicatedOf(_ audio: Audio) -> Audio? {
        do {
            let hash = audio.fileHash
            let url = audio.url
            let order = audio.order
            let duplicates = try context.fetch(FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
                $0.fileHash == hash &&
                    $0.url != url &&
                    $0.order < order &&
                    $0.fileHash.count > 0
            }, sortBy: [
                SortDescriptor(\.order, order: .forward),
            ]))

            return duplicates.first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        return nil
    }
    
    func findDuplicate(_ audio: Audio) -> Audio? {
        os_log("\(Logger.isMain)🍋 DB::findDuplicate")

        let url = audio.url
        let hash = audio.fileHash
        let predicate = #Predicate<Audio> {
            $0.fileHash == hash && $0.url != url
        }
        let descriptor = FetchDescriptor<Audio>(predicate: predicate)
        do {
            let duplicates = try context.fetch(descriptor)

            return duplicates.first
        } catch let e {
            print(e)
        }

        return nil
    }

    func findDuplicates(_ audio: Audio) -> [Audio] {
        //os_log("\(self.label)findDuplicates \(audio.title)")

        let url = audio.url
        let descriptor = FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
            $0.duplicatedOf == url
        })
        
        do {
            return try context.fetch(descriptor)
        } catch let e {
            print(e)
        }

        return []
    }
}

// MARK: Query

extension DB {
    func refresh(_ audio: Audio) -> Audio {
        if let a = find(audio.id) {
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
        audiosDir
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
    
    /// 第一个
    nonisolated func first() -> Audio? {
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
    
    /// 最后一个
    nonisolated func last() -> Audio? {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Audio> {
            $0.title != ""
        }
        var descriptor = FetchDescriptor<Audio>(predicate: predicate)
        descriptor.fetchLimit = 1
        descriptor.sortBy.append(SortDescriptor(\.order, order: .reverse))
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            print(e)
        }
        
        return nil
    }
    
    nonisolated func isAllInCloud() -> Bool {
        getTotal() > 0 && first() == nil
    }
}

// MARK: Query-Find

extension DB {
    func find(_ id: PersistentIdentifier) -> Audio? {
        context.model(for: id) as? Audio
    }
    
    func findAudio(_ id: PersistentIdentifier) -> Audio? {
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
}

// MARK: Query-Get

extension DB {
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
            }
        } catch let e {
            print(e)
        }

        return nil
    }

    /// The previous one of provided Audio
    func pre(_ audio: Audio?) -> Audio? {
        os_log("🍋 DBAudio::preOf [\(audio?.order ?? 0)] \(audio?.title ?? "nil")")
        guard let audio = audio else {
            return first()
        }

        let order = audio.order
        var descriptor = FetchDescriptor<Audio>()
        descriptor.sortBy.append(.init(\.order, order: .reverse))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order < order
        }

        do {
            let result = try context.fetch(descriptor)
            return result.first ?? last()
        } catch let e {
            print(e)
        }

        return nil
    }

    /// The next one of provided Audio
    func nextOf(_ audio: Audio) -> Audio? {
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
            return result.first ?? first()
        } catch let e {
            print(e)
        }

        return nil
    }
}

// MARK: 排序

extension DB {
    func sortRandom(_ sticky: Audio?) {
        os_log("\(Logger.isMain)\(DB.label)SortRandom")

        do {
            try context.enumerate(FetchDescriptor<Audio>(), block: {
                if $0 == sticky {
                    $0.order = 0
                } else {
                    $0.randomOrder()
                }
            })

            try context.save()
            onUpdated()
        } catch let e {
            print(e)
        }
    }

    func sort(_ sticky: Audio?) {
        os_log("\(Logger.isMain)\(DB.label)Sort")

        // 前100留给特殊用途
        var offset = 100

        do {
            try context.enumerate(FetchDescriptor<Audio>(sortBy: [
                .init(\.title, order: .forward),
            ]), block: {
                if $0 == sticky {
                    $0.order = 0
                } else {
                    $0.order = offset
                    offset = offset + 1
                }
            })

            try context.save()
            onUpdated()
        } catch let e {
            print(e)
        }
    }
}

// MARK: 修改与下载

extension DB {
    func evict(_ audio: Audio) {
        dbFolder.evict(audio.url)
    }

    func increasePlayCount(_ audio: Audio) {
        if let a = find(audio.id) {
            a.playCount += 1
            save()
        }
    }

    func download(_ audio: Audio, reason: String) {
        Task {
            await DBDownloadJob(db: self).run(audio)
        }
    }

    /// 下载当前的和当前的后面的X个
    func downloadNext(_ audio: Audio, reason: String) {
        let count = 5
        var currentIndex = 0
        var currentAudio: Audio = audio

        while currentIndex < count {
            download(currentAudio, reason: "downloadNext 🐛 \(reason)")

            currentIndex = currentIndex + 1
            if let next = nextOf(currentAudio) {
                currentAudio = next
            }
        }
    }

    func toggleLike(_ audio: Audio) {
        if let dbAudio = find(audio.id) {
            dbAudio.like.toggle()
            save()

            EventManager().emitAudioUpdate(dbAudio)
        }
    }

    func like(_ audio: Audio) {
        if let dbAudio = find(audio.id) {
            dbAudio.like = true
            save()

            EventManager().emitAudioUpdate(dbAudio)
        }
    }

    func dislike(_ audio: Audio) {
        if let dbAudio = find(audio.id) {
            dbAudio.like = false
            save()

            EventManager().emitAudioUpdate(dbAudio)
        }
    }
    
    func updateFileHash(_ audio: Audio) {
         os_log("\(self.label)updateFileHash \(audio.title)")

        guard let dbAudio = find(audio.url) else {
            return
        }

        dbAudio.fileHash = dbAudio.getHash()
        save()
    }

    func updateDuplicatedOf(_ audio: Audio) {
        // os_log("\(self.label)updateDuplicatedOf \(audio.title)")

        guard let dbAudio = find(audio.url) else {
            return
        }

        let url = dbAudio.url
        let hash = dbAudio.fileHash
        let order = dbAudio.order

        // 清空字段
        dbAudio.duplicatedOf = nil
        save()

        // 更新DuplicateOf
        do {
            let duplicates = try context.fetch(FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
                $0.fileHash == hash &&
                    $0.url != url &&
                    $0.order < order &&
                    $0.fileHash.count > 0
            }, sortBy: [
                SortDescriptor(\.order, order: .forward),
            ]))

            dbAudio.duplicatedOf = duplicates.first?.url
            EventManager().emitAudioUpdate(dbAudio)

            save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        if let d = dbAudio.duplicatedOf {
            os_log(.error, "\(self.label)\(audio.title) duplicatedOf -> \(d.lastPathComponent)")
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
            } else {
                os_log("\(Logger.isMain)🍋 DB::update not found ⚠️")
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

// MARK: Update-Duplicate

extension DB {
    nonisolated func updateDuplicatedOf(_ audio: Audio, duplicatedOf: URL?) {
        Task.detached {
            //os_log("\(Logger.isMain)🍋 DB::updateDuplicatedOf \(audio.title)")
            let context = ModelContext(self.modelContainer)
            context.autosaveEnabled = false
            
            if let current = Self.find(context, audio.url) {
                current.duplicatedOf = duplicatedOf
            } else {
                os_log("\(Logger.isMain)🍋 DB::updateDuplicatedOf not found ⚠️")
            }

            if context.hasChanges {
                try? context.save()
                await self.onUpdated()
            }
        }
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
