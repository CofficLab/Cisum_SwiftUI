import Foundation
import OSLog
import SwiftData

extension DB {
    func runDeleteInvalidJob() {
        self.runJob(
            "DeleteInvalid 🗑️🗑️🗑️",
            verbose: true,
            descriptor: Audio.descriptorAll,
            printLog: false,
            code: { audio, onEnd in
                if !FileManager.default.fileExists(atPath: audio.url.path) {
                    os_log(.error, "\(self.label)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                    self.deleteAudio(audio)
                }
                onEnd()
            })
    }
}
