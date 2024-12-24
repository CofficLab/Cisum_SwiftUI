import Foundation
import MagicKit
import OSLog

class AudioDB: ObservableObject, SuperEvent, SuperLog {
    static var emoji = "🎵"
    var db: AudioRecordDB
    var disk: (any SuperDisk)
    
    init(disk: any SuperDisk, reason: String) {
        os_log("\(Self.i) with reason: 🐛 \(reason)")
        
        self.db = AudioRecordDB(AudioConfig.getContainer, reason: "AudioPlugin", verbose: true)
        self.disk = disk
        self.disk.setDelegate(self)
        
        Task(priority: .userInitiated) {
            await disk.watch(reason: "AudioDB.init", verbose: true)
        }
    }
    
    func allAudios(reason: String) async -> [AudioModel] {
        (await self.db.allAudios(reason: reason)).map { audio in
            audio.setDB(self)
            return audio
        }
    }
    
    func delete(_ audio: AudioModel, verbose: Bool) async throws {
        self.disk.deleteFile(audio.url)
        try await self.db.deleteAudio(audio, verbose: verbose)
        self.emit(.audioDeleted)
    }
    
    func download(_ audio: AudioModel, verbose: Bool) async throws {
        try await self.disk.download(audio.url, reason: "AudioDB.download", verbose: verbose)
    }
    
    func find(_ url: URL) async -> AudioModel? {
        let audio = await self.db.findAudio(url)
        audio?.setDB(self)
        
        return audio
    }
    
    func getNextOf(_ url: URL?, verbose: Bool = false) async throws -> AudioModel? {
        try await self.db.getNextOf(url, verbose: verbose)
    }
    
    func getPrevOf(_ url: URL?, verbose: Bool = false) async throws -> AudioModel? {
        try await self.db.getPrevOf(url, verbose: verbose)
    }
    
    func getTotalCount() async -> Int {
        await self.db.getTotalOfAudio()
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
        os_log("\(self.t)🍋🍋🍋 OnDiskUpdate")
        
        await self.db.sync(items)
    }
}

extension Notification.Name {
    static let audioDeleted = Notification.Name("audioDeleted")
}
