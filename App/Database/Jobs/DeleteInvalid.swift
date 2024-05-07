import Foundation
import OSLog

class DeleteInvalid {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    var label: String { "\(Logger.isMain)🧮 DeleteInvalidJob::" }
    
    init(db: DB) {
        self.db = db
    }
    
    func run() async {
        var i = 0
        while true {
            // os_log("\(self.label)检查第 \(i) 个")
            if let audio = await self.db.get(i) {
                await self.deleteIfNeed(audio)
                i += 1
            } else {
                return
            }
        }
    }
    
    private func deleteIfNeed(_ audio: Audio) async {
        // os_log("\(Logger.isMain)🧮 检查 -> \(audio.title)")
            
        if await self.db.countOfURL(audio.url) > 1 {
            os_log("\(self.label)删除重复的数据库记录 -> \(audio.title)")
            await self.deleteAudio(audio)
        }
            
        if !FileManager.default.fileExists(atPath: audio.url.path) {
            os_log("\(self.label)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
            await self.deleteAudio(audio)
        }
    }
    
    private func deleteAudio(_ audio: Audio) async {
        await self.db.deleteAudio(audio)
    }
}
