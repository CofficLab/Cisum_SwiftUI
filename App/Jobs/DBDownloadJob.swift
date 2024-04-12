import Foundation
import OSLog

actor DBDownloadJob {
    var db: DB
    var label = "🧮 ⬇️ DBDownloadJob::"
    
    init(db: DB) {
        self.db = db
    }
    
    func run(_ audio: Audio) {
        Task.detached(operation: {
            await self.download(audio)
        })
    }
    
    private func download(_ audio: Audio) {
        if audio.isNotExists {
            return
        }
        
        if audio.isDownloaded {
            return
        }
        
        Task {
            os_log("\(Logger.isMain)\(self.label)\(audio.title)")
            do {
                try await CloudHandler().download(url: audio.url)
            } catch let e {
                print(e)
            }
        }
    }
}
