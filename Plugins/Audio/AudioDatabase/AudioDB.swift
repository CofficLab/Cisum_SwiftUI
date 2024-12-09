import Foundation
import MagicKit

class AudioDB: ObservableObject, SuperEvent {
    var db: RecordDB
    var disk: (any SuperDisk)
    
    init(db: RecordDB, disk: any SuperDisk) {
        self.db = db
        self.disk = disk
        
        self.disk.onUpdated = { items in
            Task {
                await self.db.sync(items)
            }
        }
        
        Task {
            await disk.watch(reason: "AudioDB.init", verbose: true)
        }
    }
    
    func allAudios() async -> [AudioModel] {
        (await self.db.allAudios()).map { audio in
            audio.setDB(self)
            return audio
        }
    }
    
    func delete(_ audio: AudioModel, verbose: Bool) async {
        self.disk.deleteFile(audio.url)
        await self.db.deleteAudio(audio, verbose: verbose)
        self.emit(.audioDeleted)
    }
    
    func download(_ audio: AudioModel, verbose: Bool) async throws {
        try await self.disk.download(audio.url, reason: "AudioDB.download")
    }
    
    func getTotalCount() async -> Int {
        await self.db.getTotalOfAudio()
    }
}

extension Notification.Name {
    static let audioDeleted = Notification.Name("audioDeleted")
}
