import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI
import SwiftData

class AudioDB: ObservableObject, SuperEvent, SuperLog {
    static var emoji = "🎵"
    private var db: AudioRecordDB
    private var disk: (any SuperStorage)
    
    init(disk: any SuperStorage, reason: String, verbose: Bool) {
        if verbose {
            os_log("\(Self.i) with reason: 🐛 \(reason)")
        }
        
        self.db = AudioRecordDB(AudioConfig.getContainer, reason: "AudioPlugin", verbose: verbose)
        self.disk = disk
        self.disk.setDelegate(self)
        
        Task(priority: .userInitiated) {
            await disk.watch(reason: self.className, verbose: false)
        }
    }
    
    func allAudios(reason: String) async -> [AudioModel] {
        (await self.db.allAudios(reason: reason)).map { audio in
            audio.setDB(self)
            return audio
        }
    }
    
    func changeDisk(disk: any SuperStorage) {
        os_log("\(Self.t)🍋🍋🍋 Change disk to \(disk.name)")
        
        self.disk.stopWatch(reason: self.className + ".changeDisk")
        self.disk = disk
        self.disk.setDelegate(self)
        Task(priority: .userInitiated) {
            await self.disk.watch(reason: self.className + ".changeDisk", verbose: true)
        }
    }
    
    func delete(_ audio: AudioModel, verbose: Bool) async throws {
        try self.disk.deleteFile(audio.url)
        try await self.db.deleteAudio(audio, verbose: verbose)
        self.emit(.audioDeleted)
    }
    
    func download(_ audio: AudioModel, verbose: Bool) async throws {
        try await self.disk.download(audio.url, reason: "AudioDB.download", verbose: verbose)
    }
    
    func find(_ url: URL) async -> URL? {
        let audio = await self.db.findAudio(url)
        audio?.setDB(self)
        
        return url
    }
    
    func getFirst() async throws -> URL? {
        let audio = try await self.db.firstAudio()
        
        return audio?.url
    }
    
    func getNextOf(_ url: URL?, verbose: Bool = false) async throws -> URL? {
        let audio = try await self.db.getNextOf(url, verbose: verbose)
        
        return audio?.url
    }
    
    func getPrevOf(_ url: URL?, verbose: Bool = false) async throws -> URL? {
        let audio = try await self.db.getPrevOf(url, verbose: verbose)
        
        return audio?.url
    }
    
    func getTotalCount() async -> Int {
        await self.db.getTotalOfAudio()
    }
    
    func getStorageRoot() async -> URL {
        self.disk.root
    }
    
    func sort(_ sticky: AudioModel?, reason: String) async {
        await self.db.sort(sticky, reason: reason)
    }

    func sort(_ url: URL?, reason: String) async {
        await self.db.sort(url, reason: reason)
    }

    func sortRandom(_ sticky: AudioModel?, reason: String, verbose: Bool) async throws {
        try await self.db.sortRandom(sticky, reason: reason, verbose: verbose)
    }

    func sortRandom(_ url: URL?, reason: String, verbose: Bool) async throws {
        try await self.db.sortRandom(url, reason: reason, verbose: verbose)
    }
    
    func toggleLike(_ url: URL) async throws {
        try await self.db.toggleLike(url)
    }
}

extension AudioDB: DiskDelegate {
    public func onUpdate(_ items: DiskFileGroup) async {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)🍋🍋🍋 OnDiskUpdate")
        }
        
        await self.db.sync(items)
    }
}

extension Notification.Name {
    static let audioDeleted = Notification.Name("audioDeleted")
}

// MARK: Event

extension Notification.Name {
    static let dbSyncing = Notification.Name("dbSyncing")
    static let dbSynced = Notification.Name("dbSynced")
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
}
