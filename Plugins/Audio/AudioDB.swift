import Foundation
import MagicKit

import OSLog
import SwiftData
import SwiftUI
import Combine

@MainActor class AudioDB: ObservableObject, SuperEvent, @preconcurrency SuperLog {
    static let emoji = "🎵"
    private var db: AudioRecordDB
    private var disk: URL
    private var monitor: Cancellable? = nil

    init(disk: URL, reason: String, verbose: Bool) throws {
        if verbose {
            os_log("\(Self.i) with reason: 🐛 \(reason) 💾 with disk: \(disk.shortPath())")
        }

        self.db = AudioRecordDB(try AudioConfig.getContainer(), reason: reason, verbose: verbose)
        self.disk = disk
        self.monitor = self.makeMonitor()
    }

    func allAudios(reason: String) async -> [URL] {
        await self.db.allAudioURLs(reason: reason)
    }

    func changeRoot(url: URL) {
        os_log("\(Self.t)🍋🍋🍋 Change disk to \(url.title)")

        self.monitor?.cancel()
        self.disk = url
        self.monitor = self.makeMonitor()
    }

    func delete(_ audio: AudioModel, verbose: Bool) async throws {
        try self.disk.delete()
        try await self.db.deleteAudio(url: audio.url)
        self.emit(.audioDeleted)
    }

    func download(_ audio: AudioModel, verbose: Bool) async throws {
        try await audio.url.download()
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

    func toggleLike(_ url: URL) async throws {
        try await self.db.toggleLike(url)
    }

    func makeMonitor() -> Cancellable {
        self.disk.onDirectoryChanged(verbose: false, caller: self.className, { items, isFirst in
            Task {
                self.emitDBSyncing(items)
                await self.db.sync(items, verbose: false, isFirst: isFirst)
                self.emitDBSynced()
            }
        })
    }
}

// MARK: Emit

extension AudioDB {
    func emitDBSyncing(_ items: [MetaWrapper]) {
        self.emit(name: .dbSyncing, object: self, userInfo: ["items": items])
    }
    
    func emitDBSynced() {
        self.emit(name: .dbSynced, object: nil)
    }
}

// MARK: Event

extension Notification.Name {
    static let audioDeleted = Notification.Name("audioDeleted")
    static let dbSyncing = Notification.Name("dbSyncing")
    static let dbSynced = Notification.Name("dbSynced")
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
}
