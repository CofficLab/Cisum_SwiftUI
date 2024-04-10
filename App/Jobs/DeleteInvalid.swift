import Foundation
import OSLog

class DeleteInvalid {
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
                    self.deleteIfNeed(audio)
                    i += 1
                } else {
                    return
                }
            }
        }
    }
    
    private func deleteIfNeed(_ audio: Audio) {
        // os_log("\(Logger.isMain)🧮 检查 -> \(audio.title)")
            
        if self.db.countOfURL(audio.url) > 1 {
            os_log("\(Logger.isMain)🗑️ 删除重复的 -> \(audio.title)")
            self.db.delete(audio)
            os_log("\(Logger.isMain)🗑️ 已删除重复的🎉🎉🎉 -> \(audio.title)")
        }
    }
}
