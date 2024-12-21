import Foundation
import MagicKit

class AudioDB: ObservableObject, SuperEvent {
    var db: AudioRecordDB
    var disk: (any SuperDisk)
    
    init(db: AudioRecordDB, disk: any SuperDisk) {
        self.db = db
        self.disk = disk
        
        self.disk.onUpdated = { items in
            Task {
                await self.db.sync(items)
            }
        }
        
        Task.detached(priority: .background) {
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
    
    func getTotalCount() async -> Int {
        await self.db.getTotalOfAudio()
    }
    
    func toggleLike(_ url: URL) async throws {
        try await self.db.toggleLike(url)
    }
}

extension Notification.Name {
    static let audioDeleted = Notification.Name("audioDeleted")
}
