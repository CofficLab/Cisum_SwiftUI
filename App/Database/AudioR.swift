import Foundation
import SwiftData
import OSLog

// MARK: 查询-Duplicate

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
        // os_log("\(self.label)findDuplicates \(audio.title)")

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
        if let a = findAudio(audio.id) {
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
    func findAudio(_ id: Audio.ID) -> Audio? {
        context.model(for: id) as? Audio
    }

    func findAudio(_ url: URL) -> Audio? {
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
