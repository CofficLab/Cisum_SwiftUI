import Foundation
import OSLog
import SwiftData

extension AudioRecordDB {
    func allAudios() -> [AudioModel] {
        os_log("\(self.t)GetAllAudios")
        do {
            let audios: [AudioModel] = try self.all()

            return audios
        } catch let error {
            os_log(.error, "\(error.localizedDescription)")
            return []
        }
    }

    func countOfURL(_ url: URL) -> Int {
        let descriptor = FetchDescriptor<AudioModel>(predicate: #Predicate<AudioModel> {
            $0.url == url
        })

        do {
            return try context.fetchCount(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return 0
        }
    }

    func delete(_ id: AudioModel.ID) -> AudioModel? {
        nil
    }

    func deleteAudio(_ audio: AudioModel, verbose: Bool) {
        _ = Self.deleteAudio(context: context, id: audio.id)
    }

    func deleteAudios(_ audios: [AudioModel]) -> AudioModel? {
        Self.deleteAudios(context: context, ids: audios.map { $0.id })
    }

    func deleteAudios(_ ids: [AudioModel.ID]) -> AudioModel? {
        Self.deleteAudios(context: context, ids: ids)
    }

    func destroyAudios() {
        do {
            try destroy(for: AudioModel.self)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func dislike(_ audio: AudioModel) {
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

    func download(_ url: URL, reason: String) {
        Task.detached(priority: .background) {
//            await self.disk.download(url, reason: reason)
        }
    }

    func downloadNext(_ audio: AudioModel, reason: String) {
        downloadNextBatch(audio, count: 2, reason: reason)
    }

    func downloadNextBatch(_ audio: AudioModel, count: Int = 6, reason: String) {
        var currentIndex = 0
        var currentAudio: AudioModel = audio

        while currentIndex < count {
            download(currentAudio.url, reason: "downloadNext 🐛 \(reason)")

            currentIndex = currentIndex + 1
            if let next = self.nextOf(currentAudio) {
                currentAudio = next
            }
        }
    }

    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String) {
        if let audio = findAudio(url) {
            downloadNextBatch(audio, count: count, reason: reason)
        }
    }

    func emitDBSynced() {
        self.main.async {
            NotificationCenter.default.post(name: .dbSynced, object: nil)
        }
    }

    func emitDBSyncing(_ group: DiskFileGroup) {
        self.main.async {
            NotificationCenter.default.post(name: .dbSyncing, object: self, userInfo: ["group": group])
        }
    }

    func emitSortDone() {
        os_log("\(self.t)emitSortDone")
        NotificationCenter.default.post(name: .DBSortDone, object: nil)
    }

    func emitSorting(_ mode: String) {
        let verbose = false

        if verbose {
            os_log("\(self.t)emitSorting")
        }

        NotificationCenter.default.post(name: .DBSorting, object: nil, userInfo: ["mode": mode])
    }

    func evict(_ url: URL) {
//        disk.evict(url)
    }

    func findAudio(_ id: AudioModel.ID) -> AudioModel? {
        context.model(for: id) as? AudioModel
    }

    func findAudio(_ url: URL) -> AudioModel? {
        Self.findAudio(url, context: context)
    }

    func firstAudio() -> AudioModel? {
        Self.first(context: ModelContext(self.modelContainer))
    }

    func get(_ i: Int) -> AudioModel? {
        Self.get(context: ModelContext(self.modelContainer), i)
    }

    func getAllURLs() -> [URL] {
        let context = ModelContext(self.modelContainer)

        let predicate = #Predicate<AudioModel> {
            $0.title != ""
        }
        let descriptor = FetchDescriptor<AudioModel>(predicate: predicate)
        do {
            return try context.fetch(descriptor).map { $0.url }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return []
        }
    }

    func getAudioPlayTime() -> Int {
        var time = 0

        do {
            let audios = try context.fetch(AudioModel.descriptorAll)

            audios.forEach({
                time += $0.playCount
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return time
    }

    func getChildren(_ audio: AudioModel) -> [AudioModel] {
        do {
            let result = try context.fetch(AudioModel.descriptorAll).filter({
                $0.url.deletingLastPathComponent() == audio.url
            })

            return result
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return []
    }

    func getNextOf(_ url: URL?, verbose: Bool = false) -> AudioModel? {
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

    func getPrevOf(_ url: URL?, verbose: Bool = false) -> AudioModel? {
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

    func getTotalOfAudio() -> Int {
        Self.getTotal(context: context)
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

    func increasePlayCount(_ url: URL?) {
        if let url = url {
            increasePlayCount(url)
        }
    }

    func insertAudio(_ audio: AudioModel, force: Bool = false) {
        if force == false && (findAudio(audio.url) != nil) {
            return
        }

        context.insert(audio)

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        Task {
            self.updateHash(audio)
        }
    }

    func isAllInCloud() -> Bool {
        getTotalOfAudio() > 0 && AudioRecordDB.first(context: context) == nil
    }

    func like(_ audio: AudioModel) {
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

    func nextOf(_ audio: AudioModel) -> AudioModel? {
        Self.nextOf(context: context, audio: audio)
    }

    func nextOf(_ url: URL?, verbose: Bool = false) -> AudioModel? {
        if verbose {
            os_log("\(self.t)NextOf -> \(url?.lastPathComponent ?? "-")")
        }

        guard let url = url else {
            return nil
        }

        guard let audio = self.findAudio(url) else {
            return nil
        }

        return self.nextOf(audio)
    }

    func pre(_ url: URL?) -> AudioModel? {
        os_log("🍋 DBAudio::preOf \(url?.lastPathComponent ?? "nil")")

        guard let url = url else {
            return AudioRecordDB.first(context: context)
        }

        guard let audio = self.findAudio(url) else {
            return AudioRecordDB.first(context: context)
        }

        return prev(audio)
    }

    func prev(_ audio: AudioModel?) -> AudioModel? {
        os_log("🍋 DBAudio::preOf [\(audio?.order ?? 0)] \(audio?.title ?? "nil")")
        guard let audio = audio else {
            return AudioRecordDB.first(context: context)
        }

        return Self.prevOf(context: context, audio: audio)
    }

    func refresh(_ audio: AudioModel) -> AudioModel {
        findAudio(audio.id) ?? audio
    }

    func sort(_ sticky: AudioModel?, reason: String) {
        os_log("\(Logger.isMain)\(AudioRecordDB.label)Sort with reason: \(reason)")

        emitSorting("order")

        // 前100留给特殊用途
        var offset = 100

        do {
            try context.enumerate(FetchDescriptor<AudioModel>(sortBy: [
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

    func sort(_ url: URL?, reason: String) {
        if let url = url {
            sort(findAudio(url), reason: reason)
        } else {
            sort(nil as AudioModel?, reason: reason)
        }
    }

    func sortRandom(_ sticky: AudioModel?, reason: String) {
        let verbose = true

        if verbose {
            os_log("\(self.t)SortRandom with sticky: \(sticky?.title ?? "nil") with reason: \(reason)")
        }

        emitSorting("random")

        do {
            try context.enumerate(FetchDescriptor<AudioModel>(), block: {
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

    func sortRandom(_ url: URL?, reason: String) {
        if let url = url {
            sortRandom(findAudio(url), reason: reason)
        } else {
            sortRandom(nil as AudioModel?, reason: reason)
        }
    }

    func sticky(_ url: URL?, reason: String) {
        guard let url = url else {
            return
        }

        os_log("\(Logger.isMain)\(AudioRecordDB.label)Sticky \(url.lastPathComponent) with reason: \(reason)")

        do {
            // Find the audio corresponding to the URL
            guard let audioToSticky = findAudio(url) else {
                os_log(.error, "Audio not found for URL: \(url)")
                return
            }

            // Find the currently sticky audio (if any)
            let currentStickyAudio = try context.fetch(FetchDescriptor<AudioModel>(predicate: #Predicate { $0.order == 0 })).first

            // Update orders
            audioToSticky.order = 0
            currentStickyAudio?.order = 1

            try context.save()
            onUpdated()
        } catch let e {
            os_log(.error, "Error setting sticky audio: \(e.localizedDescription)")
        }
    }

    func sync(_ group: DiskFileGroup, verbose: Bool = false) {
        self.emitDBSyncing(group)

        if verbose {
            os_log("\(self.t) Sync(\(group.count))")
        }

        if group.isFullLoad {
            syncWithDisk(group)
        } else {
            syncWithUpdatedItems(group)
        }

//        if verbose {
//            os_log("\(self.labelForSync) 计算刚刚同步的项目的 Hash(\(group.count))")
//        }
//
//        self.updateGroupForURLs(group.urls)

        self.emitDBSynced()
    }

    func syncWithDisk(_ group: DiskFileGroup) {
        let verbose = false
        let startTime: DispatchTime = .now()

        // 将数组转换成哈希表，方便通过键来快速查找元素，这样可以将时间复杂度降低到：O(m+n)
        var hashMap = group.hashMap

        do {
            try context.enumerate(FetchDescriptor<AudioModel>(), block: { audio in
                if let item = hashMap[audio.url] {
                    // 更新数据库记录
                    audio.size = item.size

                    // 记录存在哈希表中，同步完成，删除哈希表记录
                    hashMap.removeValue(forKey: audio.url)
                } else {
                    // 记录不存在哈希表中，数据库删除
                    if verbose {
                        os_log("\(self.t)删除 \(audio.title)")
                    }
                    context.delete(audio)
                }
            })

            // 余下的是需要插入数据库的
            for (_, value) in hashMap {
                context.insert(value.toAudio())
            }

            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }

        if verbose {
            os_log("\(self.jobEnd(startTime, title: "\(self.t) SyncWithDisk(\(group.count))", tolerance: 0.01))")
        }
    }

    func syncWithUpdatedItems(_ metas: DiskFileGroup, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)SyncWithUpdatedItems with count=\(metas.count)")
        }

        // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
        // 但在这里，希望如果存在，就不要插入
        for (_, meta) in metas.files.enumerated() {
            if meta.isDeleted {
                let deletedURL = meta.url

                do {
                    try context.delete(model: AudioModel.self, where: #Predicate { audio in
                        audio.url == deletedURL
                    })
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            } else {
                if findAudio(meta.url) == nil {
                    context.insert(meta.toAudio())
                }
            }
        }

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

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

    func update(_ audio: AudioModel, verbose: Bool = false) {
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

    func updateCover(_ audio: AudioModel, hasCover: Bool) {
        guard let dbAudio = context.model(for: audio.id) as? AudioModel else {
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

    func updateHash(_ audio: AudioModel, verbose: Bool = false) {
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

        guard let dbAudio = context.model(for: audio.id) as? AudioModel else {
            return
        }

        dbAudio.fileHash = fileHash

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    static func deleteAudio(context: ModelContext, id: AudioModel.ID) -> AudioModel? {
        deleteAudios(context: context, ids: [id])
    }

    static func deleteAudios(context: ModelContext, ids: [AudioModel.ID], verbose: Bool = true) -> AudioModel? {
        if verbose {
            os_log("\(Logger.isMain)\(label)数据库删除")
        }

        // 本批次的最后一个删除后的下一个
        var next: AudioModel?

        for (index, id) in ids.enumerated() {
            guard let audio = context.model(for: id) as? AudioModel else {
                os_log(.debug, "\(Logger.isMain)\(label)删除时找不到")
                continue
            }

            let url = audio.url

            // 找出本批次的最后一个删除后的下一个
            if index == ids.count - 1 {
                next = Self.nextOf(context: context, audio: audio)

                // 如果下一个等于当前，设为空
                if next?.url == url {
                    next = nil
                }
            }

            do {
                context.delete(audio)
                try context.save()
            } catch let e {
                os_log(.error, "\(Logger.isMain)\(AudioRecordDB.label)删除出错 \(e)")
            }
        }

        return next
    }

    static func deleteAudiosByURL(context: ModelContext, disk: any SuperDisk, urls: [URL]) -> AudioModel? {
        // 本批次的最后一个删除后的下一个
        var next: AudioModel?

        for (index, url) in urls.enumerated() {
            do {
                guard let audio = try context.fetch(FetchDescriptor(predicate: #Predicate<AudioModel> {
                    $0.url == url
                })).first else {
                    os_log(.debug, "\(Logger.isMain)\(label)删除时找不到")
                    continue
                }

                // 找出本批次的最后一个删除后的下一个
                if index == urls.count - 1 {
                    next = Self.nextOf(context: context, audio: audio)

                    // 如果下一个等于当前，设为空
                    if next?.url == url {
                        next = nil
                    }
                }

                // 从磁盘删除
                disk.deleteFile(audio.url)

                // 从磁盘删除后，因为数据库监听了磁盘的变动，会自动删除
                // 但自动删除可能不及时，所以这里及时删除
                context.delete(audio)

                try context.save()
            } catch let e {
                os_log(.error, "\(Logger.isMain)\(AudioRecordDB.label)删除出错 \(e)")
            }
        }

        return next
    }

    static func findAudio(_ url: URL, context: ModelContext, verbose: Bool = false) -> AudioModel? {
        if verbose {
            os_log("\(self.label)FindAudio -> \(url.lastPathComponent)")
        }

        do {
            return try context.fetch(FetchDescriptor<AudioModel>(predicate: #Predicate<AudioModel> {
                $0.url == url
            })).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    static func first(context: ModelContext) -> AudioModel? {
        var descriptor = FetchDescriptor<AudioModel>(predicate: #Predicate<AudioModel> {
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

    static func get(context: ModelContext, _ i: Int) -> AudioModel? {
        var descriptor = FetchDescriptor<AudioModel>()
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

    static func getTotal(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor(predicate: #Predicate<AudioModel> {
            $0.order != -1
        })

        do {
            return try context.fetchCount(descriptor)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return 0
        }
    }

    static func nextOf(context: ModelContext, audio: AudioModel) -> AudioModel? {
        // os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
        let order = audio.order
        let url = audio.url
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order >= order && $0.url != url
        }

        do {
            let result = try context.fetch(descriptor)
            let next = result.first ?? Self.first(context: context)
            // os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> [\(next?.order ?? -1)] \(next?.title ?? "-")")
            return next
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    static func prevOf(context: ModelContext, audio: AudioModel, verbose: Bool = false) -> AudioModel? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)PrevOf [\(audio.order)] \(audio.title)")
        }

        let order = audio.order
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .reverse))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order < order
        }

        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
}

// MARK: Event

extension Notification.Name {
    static let dbSyncing = Notification.Name("dbSyncing")
    static let dbSynced = Notification.Name("dbSynced")
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
}
