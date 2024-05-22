import Foundation
import OSLog
import SwiftData

// MARK: Query

extension DB {
    func refresh(_ audio: Audio) -> Audio {
        findAudio(audio.id) ?? audio
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

    func getAllURLs() -> [URL] {
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
        //os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
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
            let next = result.first ?? Self.first(context: context)
            //os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> [\(next?.order ?? -1)] \(next?.title ?? "-")")
            return next
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
    func get(_ i: Int) -> Audio? {
        Self.get(context: ModelContext(self.modelContainer), i)
    }
}

// MARK: PlayTime

extension DB {
    func getAudioPlayTime() -> Int {
        var time = 0
        
        do {
            let audios = try context.fetch(Audio.descriptorAll)
            
            audios.forEach({
                time += $0.playCount
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        return time
    }
}
