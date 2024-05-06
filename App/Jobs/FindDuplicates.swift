import Foundation
import OSLog

class FindDuplicates {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    
    init(db: DB) {
        self.db = db
    }
    
    func run() {
        var i = 0
        queue.sync {
            while true {
                os_log("\(Logger.isMain)🧮 检查第 \(i) 个")
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
        os_log("\(Logger.isMain)🧮 检查 -> \(audio.title)")
            
        Task {
            await self.db.updateDuplicates(audio)
        }
    }
}
