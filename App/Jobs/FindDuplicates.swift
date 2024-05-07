import Foundation
import OSLog

class FindDuplicates {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    var label: String { "\(Logger.isMain)📁 FindDuplicates::" }
    
    init(db: DB) {
        self.db = db
    }
    
    func run() {
        var i = 0
        queue.sync {
            while true {
                // os_log("\(self.label)检查第 \(i) 个")
                if let audio = self.db.get(i) {
                    self.findDuplicates(audio)
                    i += 1
                } else {
                    return
                }
            }
        }
    }
    
    private func findDuplicates(_ audio: Audio) {
        Task(priority: .background) {
            os_log("\(self.label)检查 -> \(audio.title)")
            if audio.fileHash.isEmpty {
                audio.fileHash = audio.getHash()
            }
            
            let duplicatedOf = await self.db.findDuplicatedOf(audio)
            
            if let url = duplicatedOf?.url {
                os_log(.error, "\(self.label)\(audio.title) is duplicated of \(url.lastPathComponent)")
                self.db.updateDuplicatedOf(audio, duplicatedOf: url)
            }
        }
    }
}
