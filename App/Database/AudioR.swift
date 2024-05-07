import Foundation
import OSLog
import SwiftData

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
    func first() -> Audio? {
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
    func getTotal() -> Int {
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

    /// 查询数据库中的按照order排序的第x个
    func get(_ i: Int) -> Audio? {
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
