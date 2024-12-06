import Foundation
import OSLog
import SwiftData
import SwiftUI

extension DB {
    func update(_ audio: Audio, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)update \(audio.title)")
        }

        if var current = findAudio(audio.id) {
            if audio.isDeleted {
                context.delete(current)
            } else {
                current = audio
            }
        } else {
            if verbose {
                os_log("\(self.t)🍋 DB::update not found ⚠️")
            }
        }

        if context.hasChanges {
            try? context.save()
            onUpdated()
        } else {
            os_log("\(self.t)🍋 DB::update nothing changed 👌")
        }
    }
}

// MARK: 播放次数

extension DB {
    func increasePlayCount(_ url: URL?) {
        if let url = url {
            increasePlayCount(url)
        }
    }

    func increasePlayCount(_ url: URL) {
        if let a = findAudio(url) {
            a.playCount += 1
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
                print(e)
            }
        }
    }
}

// MARK: Download

extension DB {
    func evict(_ url: URL) {
//        disk.evict(url)
    }

    func download(_ url: URL, reason: String) {
        Task.detached(priority: .background) {
//            await self.disk.download(url, reason: reason)
        }
    }

    /// 下载当前的和当前的后面的X个
    func downloadNext(_ audio: Audio, reason: String) {
        downloadNextBatch(audio, count: 2, reason: reason)
    }

    /// 下载当前的和当前的后面的X个
    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String) {
        if let audio = findAudio(url) {
            downloadNextBatch(audio, count: count, reason: reason)
        }
    }

    /// 下载当前的和当前的后面的X个
    func downloadNextBatch(_ audio: Audio, count: Int = 6, reason: String) {
        var currentIndex = 0
        var currentAudio: Audio = audio

        while currentIndex < count {
            download(currentAudio.url, reason: "downloadNext 🐛 \(reason)")

            currentIndex = currentIndex + 1
            if let next = self.nextOf(currentAudio) {
                currentAudio = next
            }
        }
    }
}

// MARK: LIKE

extension DB {
    func toggleLike(_ url: URL) {
        if let dbAudio = findAudio(url) {
            dbAudio.like.toggle()
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }

            emitAudioUpdate(dbAudio)
        }
    }

    func like(_ audio: Audio) {
        if let dbAudio = findAudio(audio.id) {
            dbAudio.like = true
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }

            emitAudioUpdate(dbAudio)
        }
    }

    func dislike(_ audio: Audio) {
        if let dbAudio = findAudio(audio.id) {
            dbAudio.like = false
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }

            emitAudioUpdate(dbAudio)
        }
    }
}

// MARK: 排序

extension DB {
    func sortRandom(_ url: URL?, reason: String) {
        if let url = url {
            sortRandom(findAudio(url), reason: reason)
        } else {
            sortRandom(nil as Audio?, reason: reason)
        }
    }

    func sortRandom(_ sticky: Audio?, reason: String) {
        let verbose = true

        if verbose {
            os_log("\(self.t)SortRandom with sticky: \(sticky?.title ?? "nil") with reason: \(reason)")
        }

        emitSorting("random")

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
            emitSortDone()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            emitSortDone()
        }
    }

    func sort(_ url: URL?, reason: String) {
        if let url = url {
            sort(findAudio(url), reason: reason)
        } else {
            sort(nil as Audio?, reason: reason)
        }
    }

    func sort(_ sticky: Audio?, reason: String) {
        os_log("\(Logger.isMain)\(DB.label)Sort with reason: \(reason)")

        emitSorting("order")

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
            emitSortDone()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            emitSortDone()
        }
    }

    func sticky(_ url: URL?, reason: String) {
        guard let url = url else {
            return
        }

        os_log("\(Logger.isMain)\(DB.label)Sticky \(url.lastPathComponent) with reason: \(reason)")

        do {
            // Find the audio corresponding to the URL
            guard let audioToSticky = findAudio(url) else {
                os_log(.error, "Audio not found for URL: \(url)")
                return
            }

            // Find the currently sticky audio (if any)
            let currentStickyAudio = try context.fetch(FetchDescriptor<Audio>(predicate: #Predicate { $0.order == 0 })).first

            // Update orders
            audioToSticky.order = 0
            currentStickyAudio?.order = 1

            try context.save()
            onUpdated()
        } catch let e {
            os_log(.error, "Error setting sticky audio: \(e.localizedDescription)")
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

// MARK: Hash

extension DB {
    func updateHash(_ audio: Audio, verbose: Bool = false) {
        if audio.isNotDownloaded {
            return
        }

        if verbose {
            os_log("\(self.t)UpdateHash for \(audio.title) 🌾🌾🌾 \(audio.getFileSizeReadable())")
        }

        let fileHash = audio.getHash()
        if fileHash.isEmpty {
            return
        }

        guard let dbAudio = context.model(for: audio.id) as? Audio else {
            return
        }

        dbAudio.fileHash = fileHash

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

// MARK: Event Name

extension Notification.Name {
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
}

// MARK: Event Emit

extension DB {
    func emitSorting(_ mode: String) {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)emitSorting")
        }
        
        NotificationCenter.default.post(name: .DBSorting, object: nil, userInfo: ["mode": mode])
    }

    func emitSortDone() {
        os_log("\(self.t)emitSortDone")
        NotificationCenter.default.post(name: .DBSortDone, object: nil)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
