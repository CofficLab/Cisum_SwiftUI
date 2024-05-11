import Foundation
import OSLog
import SwiftData

// MARK: 查询-Duplicate

extension DB {
    /// 排序在当前audio前的相同的audio中的第一个
    static func getFirstDuplicate(context: ModelContext, audio: Audio) -> Audio? {
        Self.getPreDuplicates(context: context, audio: audio).first
    }
    
    /// 排序在当前audio前的相同的audio
    static func getPreDuplicates(context: ModelContext, audio: Audio) -> [Audio] {
        let url = audio.url
        let order = audio.order
        let hash = audio.fileHash
        
        if hash.isEmpty {
            return []
        }
        
        do {
            return try context.fetch(FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
                $0.fileHash == hash &&
                    $0.url != url &&
                    $0.order < order &&
                    $0.fileHash.count > 0
            }, sortBy: [
                SortDescriptor(\.order, order: .forward),
            ]))
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        return []
    }

    /// 当前Audio是不是前面某个Audio的Duplicate，是则返回前面的Audio
    func findDuplicatedOf(_ audio: Audio) -> Audio? {
        guard let dbAudio = self.findAudio(audio.url) else {
            return nil
        }
        
        // 如果这个文件未下载，要等下载完才能计算hash
        if dbAudio.fileHash.isEmpty {
            dbAudio.fileHash = dbAudio.getHash()
            
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
                return nil
            }
        }
        
        do {
            let hash = dbAudio.fileHash
            let url = dbAudio.url
            let order = dbAudio.order
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
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    func findDuplicates(_ audio: Audio) -> [Audio] {
        // os_log("\(self.label)findDuplicates \(audio.title)")

        let url = audio.url
        let descriptor = FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
            $0.duplicatedOf == url
        })

        do {
            return try context.fetch(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return []
    }
}

// MARK: Query

extension DB {
    func refresh(_ audio: Audio) -> Audio {
        if let a = findAudio(audio.id) {
            return a
        } else {
            return audio
        }
    }

    func countOfURL(_ url: URL) -> Int {
        let descriptor = FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
            $0.url == url
        })

        do {
            return try context.fetchCount(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return 0
        }
    }

    func getAudioDir() -> URL {
        self.disk.audiosDir
    }

    nonisolated func getAllURLs() -> [URL] {
        let context = ModelContext(self.modelContainer)
        
        let predicate = #Predicate<Audio> {
            $0.title != ""
        }
        let descriptor = FetchDescriptor<Audio>(predicate: predicate)
        do {
            return try context.fetch(descriptor).map { $0.url }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return []
        }
    }

    /// 最后一个
    func last() -> Audio? {
        var descriptor = FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
            $0.title != ""
        }, sortBy: [
            SortDescriptor(\.order, order: .reverse)
        ])
        descriptor.fetchLimit = 1
        
        do {
            return try context.fetch(descriptor).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    func isAllInCloud() -> Bool {
        getTotal() > 0 && first() == nil
    }
}

// MARK: All

extension DB {
    func allAudios() -> [Audio] {
        os_log("\(self.label)GetAllAudios")
        do {
            let audios:[Audio] = try self.all()
            
            return audios
        } catch let error {
            os_log(.error, "\(error.localizedDescription)")
            return []
        }
    }
}

// MARK: First

extension DB {
    static func first(context: ModelContext) -> Audio? {
        var descriptor = FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
            $0.title != ""
        }, sortBy: [
            SortDescriptor(\.order, order: .forward),
        ])
        descriptor.fetchLimit = 1

        do {
            return try context.fetch(descriptor).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    /// 第一个
    func first() -> Audio? {
        Self.first(context: context)
    }
}

// MARK: Query-Next & Prev

extension DB {
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
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    /// The next one of provided Audio
    func nextOf(_ audio: Audio) -> Audio? {
        Self.nextOf(context: context, audio: audio)
    }
    
    static func nextOf(context: ModelContext, audio: Audio) -> Audio? {
        // os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
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
            return result.first ?? Self.first(context: context)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
}

// MARK: Query-Find

extension DB {
    static func findAudio(context: ModelContext, _ url: URL) -> Audio? {
        //os_log("\(Logger.isMain)\(Self.label)FindAudio -> \(url.lastPathComponent)")
        
        let predicate = #Predicate<Audio> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<Audio>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
    
    func findAudio(_ id: Audio.ID) -> Audio? {
        context.model(for: id) as? Audio
    }

    func findAudio(_ url: URL) -> Audio? {
        Self.findAudio(context: context, url)
    }
}

// MARK: Query-Get

extension DB {
    static func getTotalOfFileHashEmpty(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor(predicate: #Predicate<Audio> {
            $0.fileHash == ""
        })
        
        do {
            return try context.fetchCount(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return 0
        }
    }
    
    static func getTotal(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor(predicate: #Predicate<Audio> {
            $0.order != -1
        })
        
        do {
            return try context.fetchCount(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return 0
        }
    }
    
    func getTotal() -> Int {
        Self.getTotal(context: context)
    }
}

// MARK: Get by index

extension DB {
    /// 查询数据库中的按照order排序的第i个，i从0开始
    static func get(context: ModelContext, _ i: Int) -> Audio? {
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
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    /// 查询数据库中的按照order排序的第x个
    nonisolated func get(_ i: Int) -> Audio? {
        Self.get(context: ModelContext(self.modelContainer), i)
    }
}
