import Foundation
import OSLog

class DBFindDuplicates {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    var label: String { "\(Logger.isMain)📁 FindDuplicates::" }
    
    init(db: DB) {
        self.db = db
    }
    
    func run() {
        Task {
            var i = 0
            while true {
                // os_log("\(self.label)检查第 \(i) 个")
                if let audio = await self.db.get(i) {
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
            // os_log("\(self.label)检查 -> \(audio.title)")
            let duplicatedOf = await self.db.findDuplicatedOf(audio)
            await self.db.updateDuplicatedOf(audio, duplicatedOf: duplicatedOf?.url)
        }
    }
}
