import Combine
import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor AudioDB: ObservableObject, SuperEvent, SuperLog {
    nonisolated static let emoji = "🎵"
    private var db: AudioRecordDB
    private var disk: URL
    private var monitor: Cancellable?
    private var currentSyncTask: Task<Void, Never>?
    private var isShuttingDown: Bool = false

    init(disk: URL, reason: String, verbose: Bool) async throws {
        if verbose {
            os_log("\(Self.i) with reason: 🐛 \(reason) 💾 with disk: \(disk.shortPath())")
        }

        let container = try await AudioConfig.getContainer()
        self.db = AudioRecordDB(container, reason: reason, verbose: verbose)
        self.disk = disk
        self.monitor = self.makeMonitor()
    }

    func allAudios(reason: String) async -> [URL] {
        await self.db.allAudioURLs(reason: reason)
    }

    nonisolated func changeRoot(url: URL) {
        os_log("\(Self.t)🍋🍋🍋 Change disk to \(url.title)")

        Task { [weak self] in
            await self?.cleanup()
            await self?.updateDisk(url)
        }
    }

    private func updateDisk(_ url: URL) {
        self.disk = url
        self.monitor = self.makeMonitor()
    }

    func delete(_ audio: AudioModel, verbose: Bool) async throws {
        try self.disk.delete()
        try await self.db.deleteAudio(url: audio.url)
        self.emit(.dbDeleted)
    }

    func find(_ url: URL) async -> URL? {
        await self.db.hasAudio(url) ? url : nil
    }

    func getFirst() async throws -> URL? {
        try await self.db.firstAudioURL()
    }

    func getNextOf(_ url: URL?, verbose: Bool = false) async throws -> URL? {
        try await self.db.getNextAudioURLOf(url, verbose: verbose)
    }

    func getPrevOf(_ url: URL?, verbose: Bool = false) async throws -> URL? {
        try await self.db.getPrevAudioURLOf(url, verbose: verbose)
    }

    func getTotalCount() async -> Int {
        await self.db.getTotalOfAudio()
    }

    func getStorageRoot() async -> URL {
        self.disk
    }

    func isLiked(_ url: URL) async -> Bool {
        await self.db.isLiked(url)
    }

    func like(_ url: URL?, liked: Bool) async {
        guard let url = url else { return }

        if liked {
            os_log("\(self.t)👍 Like \(url.lastPathComponent)")
            await self.db.like(url)
        } else {
            os_log("\(self.t)👎 Dislike \(url.lastPathComponent)")
            await self.db.dislike(url)
        }
    }

    func sort(_ sticky: AudioModel?, reason: String) async {
        await self.db.sort(sticky?.url, reason: reason)
    }

    func sort(_ url: URL?, reason: String) async {
        await self.db.sort(url, reason: reason)
    }

    func sortRandom(_ sticky: AudioModel?, reason: String, verbose: Bool) async throws {
        try await self.db.sortRandom(sticky?.url, reason: reason, verbose: verbose)
    }

    func sortRandom(_ url: URL?, reason: String, verbose: Bool) async throws {
        try await self.db.sortRandom(url, reason: reason, verbose: verbose)
    }

    func sync(_ items: [URL], verbose: Bool = false, isFirst: Bool) async {
        guard !isShuttingDown else { return }

        currentSyncTask?.cancel()

        let task = Task(priority: .utility) { [weak self] in
            guard let self = self else { return }

            let shouldContinue = await Task.detached { await !self.isShuttingDown }.value
            guard shouldContinue == true else { return }

            if isFirst {
                await self.onDBSyncing(items)
                await self.db.initItems(items, verbose: verbose)
                await self.emitDBSynced()
            } else {
                await self.db.syncWithUpdatedItems(items, verbose: verbose)
            }

            let shouldEmit = await Task.detached { await !self.isShuttingDown }.value
            guard shouldEmit == true else { return }
        }

        currentSyncTask = task
    }

    func toggleLike(_ url: URL) async throws {
        try await self.db.toggleLike(url)
    }

    func makeMonitor() -> Cancellable {
        info("Make monitor for: \(self.disk.shortPath())")

        if self.disk.isNotDirExist {
            info("Error: \(self.disk.shortPath()) not exist")
        }

        let debounceInterval = 2.0

        return self.disk.onDirChange(
            verbose: false,
            caller: self.className,
            onChange: { [weak self] items, isFirst, _ in
                guard let self = self else { return }

                @Sendable func handleChange() async {
                    guard !(await self.isShuttingDown) else { return }

                    if let lastTime = UserDefaults.standard.object(forKey: "LastUpdateTime") as? Date {
                        let now = Date()
                        guard now.timeIntervalSince(lastTime) >= debounceInterval else { return }
                    }
                    UserDefaults.standard.set(Date(), forKey: "LastUpdateTime")

                    await self.sync(items, verbose: false, isFirst: isFirst)
                }

                Task {
                    await handleChange()
                }
            },
            onDeleted: { [weak self] urls in
                guard let self = self else { return }

                Task {
                    if urls.count > 0 {
                        try? await self.db.deleteAudios(urls)
                        await self.emitDeleted(urls)
                    }
                }
            },
            onProgress: { [weak self] url, progress in
                guard let self = self else { return }
                Task {
                    await self.emitDownloadProgress(url: url, progress: progress)
                }
            })
    }

    nonisolated func prepareForDeinit() {
        Task { [weak self] in
            await self?.cleanup()
        }
    }

    private func cleanup() async {
        isShuttingDown = true
        currentSyncTask?.cancel()
        monitor?.cancel()
        monitor = nil
        currentSyncTask = nil
    }

    deinit {
        prepareForDeinit()
    }
}

// MARK: Event

extension AudioDB {
    func onDBSyncing(_ items: [URL]) {
        info("Syncing \(items.count) items")
        os_log("\(self.t)🔄 Syncing \(items.count) items")
        self.emit(name: .dbSyncing, object: self, userInfo: ["items": items])
    }

    func emitDBSynced() {
        info("Sync Done")
        os_log("\(self.t)✅ Sync Done")
        self.emit(name: .dbSynced, object: nil)
    }

    func emitDownloadProgress(url: URL, progress: Double) {
        self.emit(name: .audioDownloadProgress,
                  object: nil,
                  userInfo: ["url": url, "progress": progress])
    }

    func emitDeleted(_ urls: [URL]) {
        self.emit(name: .dbDeleted,
                  object: nil,
                  userInfo: ["urls": urls])
    }
}

// MARK: Event Name

extension Notification.Name {
    static let dbSyncing = Notification.Name("dbSyncing")
    static let dbSynced = Notification.Name("dbSynced")
    static let dbDeleted = Notification.Name("dbDeleted")
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
    static let audioDownloadProgress = Notification.Name("audioDownloadProgress")
}
