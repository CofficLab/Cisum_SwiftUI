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

    func isAllInCloud() -> Bool {
        getTotalOfAudio() > 0 && first() == nil
    }
}

// MARK: Last

extension DB {
    /// 最后一个
    func last() -> Audio? {
        Self.last(context)
    }
    
    static func last(_ context: ModelContext) -> Audio? {
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

// MARK: Next

extension DB {
    nonisolated func getNextOf(_ url: URL?, verbose: Bool = false) -> Audio? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)NextOf -> \(url?.lastPathComponent ?? "-")")
        }
        
        guard let url = url else {
            return nil
        }
        
        let context = ModelContext(self.modelContainer)
        guard let audio = Self.findAudio(url, context: context) else {
            return nil
        }
        
        return Self.nextOf(context: context, audio: audio)
    }
    
    /// The next one of provided URL
    func nextOf(_ url: URL?, verbose: Bool = false) -> Audio? {
        if verbose {
            os_log("\(self.label)NextOf -> \(url?.lastPathComponent ?? "-")")
        }
        
        guard let url = url else {
            return nil
        }
        
        guard let audio = self.findAudio(url) else {
            return nil
        }
        
        return self.nextOf(audio)
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

// MARK: Prev

extension DB {
    /// The previous one of provided URL
    func pre(_ url: URL?) -> Audio? {
        os_log("🍋 DBAudio::preOf \(url?.lastPathComponent ?? "nil")")
        
        guard let url = url else {
            return first()
        }

        guard let audio = self.findAudio(url) else {
            return first()
        }

        return prev(audio)
    }
    
    /// The previous one of provided Audio
    func prev(_ audio: Audio?) -> Audio? {
        os_log("🍋 DBAudio::preOf [\(audio?.order ?? 0)] \(audio?.title ?? "nil")")
        guard let audio = audio else {
            return first()
        }

        return Self.prevOf(context: context, audio: audio)
    }
    
    nonisolated func getPrevOf(_ url: URL?, verbose: Bool = false) -> Audio? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)PrevOf -> \(url?.lastPathComponent ?? "-")")
        }
        
        guard let url = url else {
            return nil
        }
        
        let context = ModelContext(self.modelContainer)
        guard let audio = Self.findAudio(url, context: context) else {
            return nil
        }
        
        return Self.prevOf(context: context, audio: audio)
    }
    
    static func prevOf(context: ModelContext, audio: Audio, verbose: Bool = true) -> Audio? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)PrevOf [\(audio.order)] \(audio.title)")
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
            return result.first ?? Self.last(context)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
}

// MARK: Query-Find

extension DB {
    static func findAudio(_ url: URL, context: ModelContext, verbose: Bool = false) -> Audio? {
        if verbose {
            os_log("\(self.label)FindAudio -> \(url.lastPathComponent)")
        }
        
        do {
            return try context.fetch(FetchDescriptor<Audio>(predicate: #Predicate<Audio> {
                $0.url == url
            })).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
    
    func findAudio(_ url: URL) -> Audio? {
        Self.findAudio(url, context: context)
    }
    
    func findAudio(_ id: Audio.ID) -> Audio? {
        context.model(for: id) as? Audio
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
    
    func getTotalOfAudio() -> Int {
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

// MARK: Children

extension DB {
    func getChildren(_ audio: Audio) -> [Audio] {
        do {
            let result = try context.fetch(Audio.descriptorAll).filter({
                $0.url.deletingLastPathComponent() == audio.url
            })
            
            return result
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        return []
    }
}
