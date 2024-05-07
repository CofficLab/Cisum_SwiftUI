import Foundation
import OSLog

class DeleteInvalid {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    var label: String { "\(Logger.isMain)🧮 DeleteInvalid::"}
    
    init(db: DB) {
        self.db = db
    }
    
    func run() {
        var i = 0
        queue.sync {
            while true {
                //os_log("\(self.label)检查第 \(i) 个")
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
            
        Task {
            if await self.db.countOfURL(audio.url) > 1 {
                os_log("\(self.label)删除重复的数据库记录 -> \(audio.title)")
                self.deleteAudio(audio)
            }
            
            if !FileManager.default.fileExists(atPath: audio.url.path) {
                os_log("\(self.label)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                self.deleteAudio(audio)
            }
        }
    }
    
    private func deleteAudio(_ audio: Audio) {
        Task {
            await self.db.deleteAudio(audio)
        }
    }
}
