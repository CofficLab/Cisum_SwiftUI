import Foundation
import OSLog
import SwiftData

extension DB {
    var labelForDelete: String { "\(t)🗑️🗑️🗑️" }

    func runDeleteInvalidJob() {
        os_log("\(self.labelForDelete)🚀🚀🚀")

        do {
            try context.enumerate(Audio.descriptorAll, block: { audio in
                if !FileManager.default.fileExists(atPath: audio.url.path) {
                    os_log(.error, "\(self.t)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                    self.deleteAudio(audio)
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
