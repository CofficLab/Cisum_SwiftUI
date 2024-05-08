import Foundation
import OSLog
import SwiftData

// MARK: 修改与下载

extension DB {
    func evict(_ audio: Audio) {
        disk.evict(audio.url)
    }

    func increasePlayCount(_ audio: Audio) {
        if let a = findAudio(audio.id) {
            a.playCount += 1
            save()
        }
    }
}

// MARK: Download

extension DB {
    nonisolated func download(_ audio: Audio, reason: String) {
        Task {
            //os_log("\(Logger.isMain)\(Self.label)Download ⏬⏬⏬ \(audio.title) reason -> \(reason)")
            await disk.download(audio)
        }
    }

    /// 下载当前的和当前的后面的X个
    nonisolated func downloadNext(_ audio: Audio, reason: String) {
        let count = 2
        var currentIndex = 0
        var currentAudio: Audio = audio

        while currentIndex < count {
            download(currentAudio, reason: "downloadNext 🐛 \(reason)")

            currentIndex = currentIndex + 1
            if let next = Self.nextOf(context: ModelContext(self.modelContainer), audio: currentAudio) {
                currentAudio = next
            }
        }
    }
}

extension DB {
    func toggleLike(_ audio: Audio) {
        if let dbAudio = findAudio(audio.id) {
            dbAudio.like.toggle()
            save()

            EventManager().emitAudioUpdate(dbAudio)
        }
    }

    func like(_ audio: Audio) {
        if let dbAudio = findAudio(audio.id) {
            dbAudio.like = true
            save()

            EventManager().emitAudioUpdate(dbAudio)
        }
    }

    func dislike(_ audio: Audio) {
        if let dbAudio = findAudio(audio.id) {
            dbAudio.like = false
            save()

            EventManager().emitAudioUpdate(dbAudio)
        }
    }

    func update(_ audio: Audio) {
        if verbose {
            os_log("\(self.label)update \(audio.title)")
        }

        if var current = findAudio(audio.id) {
            if audio.isDeleted {
                context.delete(current)
            } else {
                current = audio
            }
        } else {
            if verbose {
                os_log("\(self.label)🍋 DB::update not found ⚠️")
            }
        }

        if context.hasChanges {
            try? context.save()
            onUpdated()
        } else {
            os_log("\(self.label)🍋 DB::update nothing changed 👌")
        }
    }
}

// MARK: FileHash

extension DB {
    /// 更新按照order排序的第i个的FileHash
    func updateFileHash(_ i: Int) {
        // os_log("\(Logger.isMain)\(DB.label)updateFileHash \(audio.title)")
        guard let audio = Self.get(context: context, i) else {
            return
        }

        if audio.fileHash.count > 0 {
            return
        }

        audio.fileHash = audio.getHash()

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    nonisolated func updateFileHash(_ audio: Audio, hash: String) {
        // os_log("\(Logger.isMain)\(DB.label)updateFileHash \(audio.title)")
        let context = ModelContext(self.modelContainer)
        let url = audio.url

        do {
            guard let dbAudio = try context.fetch(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.fileHash == "" && $0.url == url
            })).first else {
                return
            }

            dbAudio.fileHash = hash
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

// MARK: Duplicate

extension DB {
    // nonisolated 是为了能让其在后台运行
    nonisolated func updateDuplicatedOf(_ audio: Audio) {
        // os_log("\(Logger.isMain)\(Self.label)updateDuplicatedOf \(audio.title)")

        let context = ModelContext(self.modelContainer)
        context.autosaveEnabled = false

        guard let dbAudio = context.model(for: audio.id) as? Audio else {
            return
        }

        let url = dbAudio.url
        let hash = dbAudio.fileHash
        let order = dbAudio.order

        // 清空字段
        dbAudio.duplicatedOf = nil

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

            for duplicate in duplicates {
                if duplicate.isExists {
                    dbAudio.duplicatedOf = duplicates.first?.url
                    EventManager().emitAudioUpdate(dbAudio)

                    try context.save()

                    break
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

//        if let d = dbAudio.duplicatedOf {
        // os_log(.error, "\(Logger.isMain)\(Self.label)\(audio.title) duplicatedOf -> \(d.lastPathComponent)")
//        }
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
