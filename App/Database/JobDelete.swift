import Foundation
import OSLog

extension DB {
    func deleteInvalid() {
        Task.detached(priority: .low, operation: {
            let label = "\(Logger.isMain)\(Self.label)"
            var i = 0
            while true {
                // os_log("\(self.label)检查第 \(i) 个")
                if let audio = self.get(i) {
                    if !FileManager.default.fileExists(atPath: audio.url.path) {
                        os_log("\(label)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                        self.deleteAudio(audio)
                    }
                    
                    i += 1
                } else {
                    return
                }
            }
        })
    }
}
