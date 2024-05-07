import Foundation
import OSLog
import SwiftData

// MARK: 修改与下载

extension DB {
    func evict(_ audio: Audio) {
        dbFolder.evict(audio.url)
    }

    func increasePlayCount(_ audio: Audio) {
        if let a = findAudio(audio.id) {
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

    func updateFileHash(_ audio: Audio) {
        os_log("\(self.label)updateFileHash \(audio.title)")

        guard let dbAudio = findAudio(audio.url) else {
            return
        }

        dbAudio.fileHash = dbAudio.getHash()
        save()
    }

    func updateDuplicatedOf(_ audio: Audio) {
        // os_log("\(self.label)updateDuplicatedOf \(audio.title)")

        guard let dbAudio = findAudio(audio.url) else {
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

    func update(_ audio: Audio) {
        os_log("\(self.label)update \(audio.title)")

        if var current = findAudio(audio.id) {
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
            self.onUpdated()
        } else {
            os_log("\(Logger.isMain)🍋 DB::update nothing changed 👌")
        }
    }
}

// MARK: Update-Duplicate

extension DB {
    func updateDuplicatedOf(_ audio: Audio, duplicatedOf: URL?) {
        // os_log("\(Logger.isMain)🍋 DB::updateDuplicatedOf \(audio.title)")
        if let current = findAudio(audio.id) {
            current.duplicatedOf = duplicatedOf
        } else {
            os_log("\(Logger.isMain)🍋 DB::updateDuplicatedOf not found ⚠️")
        }

        if context.hasChanges {
            try? context.save()
            self.onUpdated()
        }
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
