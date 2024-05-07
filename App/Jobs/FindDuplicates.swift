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
                //os_log("\(self.label)检查第 \(i) 个")
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
        os_log("\(self.label)检查 -> \(audio.title)")
            
        Task {
            if audio.fileHash.isEmpty {
                await self.db.updateFileHash(audio)
            }
            
            await self.db.updateDuplicatedOf(audio)
        }
    }
}
