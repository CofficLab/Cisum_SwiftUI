import Foundation
import OSLog
import SwiftData

// MARK: Update

extension DB {
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

// MARK: 播放次数

extension DB {
    func increasePlayCount(_ audio: Audio) {
        if let a = findAudio(audio.id) {
            a.playCount += 1
            save()
        }
    }
}

// MARK: Download

extension DB {
    func evict(_ audio: Audio) {
        disk.evict(audio.url)
    }
    
    func download(_ audio: Audio, reason: String) {
        Task.detached(priority: .background) {
            //os_log("\(Logger.isMain)\(Self.label)Download ⏬⏬⏬ \(audio.title) reason -> \(reason)")
            await self.disk.download(audio)
        }
    }

    /// 下载当前的和当前的后面的X个
    func downloadNext(_ audio: Audio, reason: String) {
        downloadNextBatch(audio, count: 2, reason: reason)
    }

    /// 下载当前的和当前的后面的X个
    func downloadNextBatch(_ audio: Audio, count: Int = 6, reason: String) {
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

// MARK: LIKE

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
            os_log(.error, "\(e.localizedDescription)")
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
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

// MARK: Cover

extension DB {
    func updateCover(_ audio: Audio, hasCover: Bool) {
        guard let dbAudio = context.model(for: audio.id) as? Audio else {
            return
        }
        
        dbAudio.hasCover = hasCover
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "保存Cover出错")
            os_log(.error, "\(e)")
        }
    }
}

// MARK: Group

extension DB {
    func updateGroup(_ audio: Audio) {
        //os_log("\(Self.label)UpdateGroup for \(audio.title) 🌽")
        let fileHash = audio.getHash()
        if fileHash.isEmpty {
            return
        }
        
        let context = ModelContext(self.modelContainer)
        context.autosaveEnabled = false
        guard let dbAudio = context.model(for: audio.id) as? Audio else {
            return
        }
        
        dbAudio.group = AudioGroup(title: audio.title, hash: fileHash)
        
//        do {
//            try context.save()
//        } catch let e {
//            os_log(.error, "\(e.localizedDescription)")
//        }
    }
    
    func updateGroup(_ audios: [Audio]) {
        audios.forEach({
            updateGroup($0)
        })
    }
}
