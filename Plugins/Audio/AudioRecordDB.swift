import Foundation
import MagicKit

import OSLog
import SwiftData
import SwiftUI

actor AudioRecordDB: ModelActor, ObservableObject, SuperLog, SuperEvent, SuperThread {
    static let emoji = "📦"
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    let context: ModelContext
    let queue = DispatchQueue(label: "DB")

    init(_ container: ModelContainer, reason: String, verbose: Bool) {
        self.modelContainer = container
        self.context = ModelContext(container)
        self.context.autosaveEnabled = false
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: self.context
        )

        if verbose {
            os_log("\(Self.i) with reason: \(reason)")
        }
    }

    func hasChanges() -> Bool {
        context.hasChanges
    }

    func insertModel(_ model: any PersistentModel) throws {
        context.insert(model)
        try context.save()
    }

    func destroy<T>(for model: T.Type) throws where T: PersistentModel {
        try context.delete(model: T.self)
    }

    /// 所有指定的model
    func all<T: PersistentModel>() throws -> [T] {
        try context.fetch(FetchDescriptor<T>())
    }

    /// 分页的方式查询model
    func paginate<T: PersistentModel>(page: Int) throws -> [T] {
        try context.fetch(FetchDescriptor<T>())
    }

    /// 获取指定条件的数量
    func getCount<T: PersistentModel>(for predicate: Predicate<T>) throws -> Int {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try context.fetchCount(descriptor)
    }

    /// 按照指定条件查询多个model
    func get<T: PersistentModel>(for predicate: Predicate<T>) throws -> [T] {
        // os_log("\(self.isMain) 🏠 LocalDB.get")
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try context.fetch(descriptor)
    }

    /// 某个model的总条数
    func count<T>(for model: T.Type) throws -> Int where T: PersistentModel {
        let descriptor = FetchDescriptor<T>(predicate: .true)
        return try context.fetchCount(descriptor)
    }

    /// 执行并输出耗时
    func printRunTime(_ title: String, tolerance: Double = 0.1, verbose: Bool = false, _ code: () -> Void) {
        if verbose {
            os_log("\(self.t)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if verbose && timeInterval > tolerance {
            os_log("\(self.t)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
        }
    }

    nonisolated func jobEnd(_ startTime: DispatchTime, title: String, tolerance: Double = 1.0) -> String {
        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if timeInterval > tolerance {
            return "\(title) \(timeInterval) 秒 🐢🐢🐢"
        }

        return "\(title) \(timeInterval) 秒 🐢🐢🐢"
    }

    func allAudios(reason: String) -> [AudioModel] {
        os_log("\(self.t)🚛 GetAllAudios 🐛 \(reason)")

        do {
            let audios: [AudioModel] = try context.fetch(AudioModel.descriptorOrderAsc)

            return audios
        } catch let error {
            os_log(.error, "\(error.localizedDescription)")
            return []
        }
    }

    func allAudioURLs(reason: String) -> [URL] {
        self.allAudios(reason: reason).map { $0.url }
    }

    func randomAudios(count: Int = 100, reason: String) -> [AudioModel] {
        os_log("\(self.t)GetRandomAudios 🐛 \(reason)")

        do {
            let audios: [AudioModel] = try self.all()
            return Array(audios.shuffled().prefix(count))
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

    func deleteAudio(url: URL) throws {
        if let audio = findAudio(url) {
            try deleteAudio(id: audio.id)
        }
    }

    func deleteAudio(_ audio: AudioModel, verbose: Bool) throws {
        try deleteAudio(id: audio.id)
    }

    func deleteAudios(_ audios: [AudioModel]) throws -> AudioModel? {
        try deleteAudios(ids: audios.map { $0.id })
    }

    func deleteAudios(_ ids: [AudioModel.ID]) throws -> AudioModel? {
        try deleteAudios(ids: ids)
    }

    func deleteAudios(_ urls: [URL]) throws {
        for url in urls {
            try deleteAudio(url: url)
        }
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

            emit(.AudioUpdatedNotification, object: dbAudio)
        }
    }

    func dislike(_ url: URL) {
        if let audio = findAudio(url) {
            dislike(audio)
        }
    }

    func downloadNext(_ audio: AudioModel, reason: String) async throws {
        try await downloadNextBatch(audio, count: 2, reason: reason)
    }

    func downloadNextBatch(_ audio: AudioModel, count: Int = 6, reason: String) async throws {
        var currentIndex = 0
        var currentAudio: AudioModel = audio

        while currentIndex < count {
            try await currentAudio.url.download()

            currentIndex = currentIndex + 1
            if let next = self.nextOf(currentAudio) {
                currentAudio = next
            }
        }
    }

    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String) async throws {
        if let audio = findAudio(url) {
            try await downloadNextBatch(audio, count: count, reason: reason)
        }
    }

    func emitSortDone(verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)🚀🚀🚀 EmitSortDone")
        }

        self.main.async {
            self.emit(name: .DBSortDone, object: nil)
        }
    }

    func emitSorting(_ mode: String, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)🚀🚀🚀 EmitSorting")
        }

        self.main.async {
            self.emit(name: .DBSorting, object: nil, userInfo: ["mode": mode])
        }
    }

    func findAudio(_ id: AudioModel.ID) -> AudioModel? {
        context.model(for: id) as? AudioModel
    }

    func findAudio(_ url: URL) -> AudioModel? {
        Self.findAudio(url, context: context)
    }

    func firstAudio() throws -> AudioModel? {
        try context.fetch(AudioModel.descriptorFirst).first
    }

    func firstAudioURL() throws -> URL? {
        try context.fetch(AudioModel.descriptorFirst).first?.url
    }

    func get(_ i: Int) -> AudioModel? {
        Self.get(context: ModelContext(self.modelContainer), i)
    }

    func hasAudio(_ url: URL) -> Bool {
        self.findAudio(url) != nil
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

    func getNextOf(_ url: URL?, verbose: Bool = false) throws -> AudioModel? {
        if verbose {
            os_log("\(self.t)NextOf -> \(url?.lastPathComponent ?? "-")")
        }

        guard let url = url else {
            return nil
        }

        guard let audio = findAudio(url) else {
            return nil
        }

        return try nextOf(audio: audio)
    }

    func getNextAudioURLOf(_ url: URL?, verbose: Bool = false) throws -> URL? {
        try self.getNextOf(url, verbose: verbose)?.url
    }

    func getPrevOf(_ url: URL?, verbose: Bool = false) throws -> AudioModel? {
        if verbose {
            os_log("\(self.t)PrevOf -> \(url?.lastPathComponent ?? "-")")
        }

        guard let url = url else {
            return nil
        }

        guard let audio = self.findAudio(url) else {
            return nil
        }

        return try prev(audio)
    }

    func getPrevAudioURLOf(_ url: URL?, verbose: Bool = false) throws -> URL? {
        try self.getPrevOf(url, verbose: verbose)?.url
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
        let url = audio.url

        if force == false && (findAudio(url) != nil) {
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
        getTotalOfAudio() > 0
    }

    func isLiked(_ url: URL) -> Bool {
        findAudio(url)?.like ?? false
    }

    func like(_ audio: AudioModel) {
        if let dbAudio = findAudio(audio.id) {
            dbAudio.like = true
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }

            emit(name: .AudioUpdatedNotification, object: dbAudio)
        }
    }

    func like(_ url: URL) {
        if let audio = findAudio(url) {
            like(audio)
        }
    }

    func nextOf(_ audio: AudioModel) -> AudioModel? {
        nextOf(audio.url, verbose: true)
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

    func prev(_ audio: AudioModel?) throws -> AudioModel? {
        guard let audio = audio else {
            return try firstAudio()
        }

        let result = try context.fetch(AudioModel.descriptorPrev(order: audio.order))
        return result.first
    }

    func refresh(_ audio: AudioModel) -> AudioModel {
        findAudio(audio.id) ?? audio
    }

    func sort(_ sticky: AudioModel?, reason: String) {
        os_log("\(self.t)Sort with reason: \(reason)")

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

    func sortRandom(_ sticky: AudioModel?, reason: String, verbose: Bool) throws {
        if verbose {
            os_log("\(self.t)🐳🐳🐳 SortRandom with sticky: \(sticky?.title ?? "nil") 🐛 \(reason)")
        }

        emitSorting("random")

        try context.enumerate(FetchDescriptor<AudioModel>(), block: {
            if $0 == sticky {
                $0.order = 0
            } else {
                $0.randomOrder()
            }
        })

        try context.save()

        emitSortDone()
    }

    func sortRandom(_ url: URL?, reason: String, verbose: Bool) throws {
        if let url = url {
            try sortRandom(findAudio(url), reason: reason, verbose: verbose)
        } else {
            try sortRandom(nil as AudioModel?, reason: reason, verbose: verbose)
        }
    }

    func sticky(_ url: URL?, reason: String) {
        guard let url = url else {
            return
        }

        os_log("\(self.t)Sticky \(url.lastPathComponent) with reason: \(reason)")

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
        } catch let e {
            os_log(.error, "Error setting sticky audio: \(e.localizedDescription)")
        }
    }

    func initItems(_ items: [URL], verbose: Bool = false) {
        let startTime: DispatchTime = .now()

        // 将数组转换成哈希表，方便通过键来快速查找元素，这样可以将时间复杂度降低到：O(m+n)

        var hashMap = [URL: URL]()
        for element in items {
            hashMap[element] = element
        }

        do {
            try context.enumerate(FetchDescriptor<AudioModel>(), block: { audio in
                if let item = hashMap[audio.url] {
                    // 更新数据库记录
                    audio.size = item.getSize()

                    // 记录存在哈希表中，同步完成，删除哈希表记录
                    hashMap.removeValue(forKey: audio.url)
                } else {
                    if verbose {
                        os_log("\(self.t)🗑️ 删除 \(audio.title)")
                    }
                    context.delete(audio)
                }
            })

            // 余下的是需要插入数据库的
            for (_, value) in hashMap {
                context.insert(AudioModel(value))
            }

            try self.context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }

        if verbose {
            os_log("\(self.jobEnd(startTime, title: "\(self.t)✅ SyncWithDisk(\(items.count))", tolerance: 0.01))")
        }
    }

    func syncWithUpdatedItems(_ metas: [URL], verbose: Bool = false) {
        // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
        // 但在这里，希望如果存在，就不要插入
        for (_, meta) in metas.enumerated() {
            if meta.isNotFileExist {
                let deletedURL = meta

                do {
                    try context.delete(model: AudioModel.self, where: #Predicate { audio in
                        audio.url == deletedURL
                    })
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            } else {
                if findAudio(meta) == nil {
                    context.insert(AudioModel(meta))
                }
                
            }
        }

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func toggleLike(_ url: URL) throws {
        if let dbAudio = findAudio(url) {
            dbAudio.like.toggle()
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")

                throw e
            }

            emit(name: .AudioUpdatedNotification, object: dbAudio)
        } else {
            throw AudioRecordDBError.ToggleLikeError(AudioRecordDBError.AudioNotFound(url))
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
        } else {
            os_log("\(self.t)🍋 DB::update nothing changed 👌")
        }
    }

    func updateLike(_ url: URL, like: Bool) throws {
        if let dbAudio = findAudio(url) {
            dbAudio.like = like
            try context.save()
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
        if audio.url.isNotDownloaded {
            return
        }

        if verbose {
            os_log("\(self.t)UpdateHash for \(audio.title) 🌾🌾🌾 \(audio.getFileSizeReadable())")
        }

        let fileHash = audio.url.getHash()
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

    @discardableResult
    func deleteAudio(id: AudioModel.ID) throws -> AudioModel? {
        try deleteAudios(ids: [id])
    }

    @discardableResult
    func deleteAudios(ids: [AudioModel.ID], verbose: Bool = true) throws -> AudioModel? {
        if verbose {
            os_log("\(self.t)数据库删除")
        }

        // 本批次的最后一个删除后的下一个
        var next: AudioModel?

        for (index, id) in ids.enumerated() {
            guard let audio = context.model(for: id) as? AudioModel else {
                os_log(.error, "\(self.t)删除时找不到")
                continue
            }

            let url = audio.url

            // 找出本批次的最后一个删除后的下一个
            if index == ids.count - 1 {
                next = try nextOf(audio: audio)

                // 如果下一个等于当前，设为空
                if next?.url == url {
                    next = nil
                }
            }

            do {
                context.delete(audio)
                try context.save()
            } catch let e {
                os_log(.error, "\(self.t)删除出错 \(e)")
            }
        }

        return next
    }

    func deleteAudiosByURL(disk: URL, urls: [URL]) throws -> AudioModel? {
        // 本批次的最后一个删除后的下一个
        var next: AudioModel?

        for (index, url) in urls.enumerated() {
            do {
                guard let audio = try context.fetch(FetchDescriptor(predicate: #Predicate<AudioModel> {
                    $0.url == url
                })).first else {
                    os_log(.error, "\(self.t)删除时找不到")
                    continue
                }

                // 找出本批次的最后一个删除后的下一个
                if index == urls.count - 1 {
                    next = try nextOf(audio: audio)

                    // 如果下一个等于当前，设为空
                    if next?.url == url {
                        next = nil
                    }
                }

                // 从磁盘删除
                try audio.url.delete()

                // 从磁盘删除后，因为数据库监听了磁盘的变动，会自动删除
                // 但自动删除可能不及时，所以这里及时删除
                context.delete(audio)

                try context.save()
            } catch let e {
                os_log(.error, "\(self.t)删除出错 \(e)")
            }
        }

        return next
    }

    static func findAudio(_ url: URL, context: ModelContext, verbose: Bool = false) -> AudioModel? {
        if verbose {
            os_log("\(self.t)FindAudio -> \(url.lastPathComponent)")
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

    func nextOf(audio: AudioModel) throws -> AudioModel? {
        let result = try context.fetch(AudioModel.descriptorNext(order: audio.order))
        if let first = result.first {
            return first
        }

        return try firstAudio()
    }
}

// MARK: Error

enum AudioRecordDBError: Error {
    case ToggleLikeError(Error)
    case AudioNotFound(URL)
}

#Preview {
    RootView {
        ContentView()
    }
}
