import Foundation
import SwiftData
import OSLog

extension DB {
    func runDeleteInvalidJob() {
        self.runJob("DeleteInvalid 🗑️🗑️🗑️", verbose: true, descriptor: Audio.descriptorAll, code: { audio,onEnd in
            if !FileManager.default.fileExists(atPath: audio.url.path) {
                os_log(.error, "\(self.label)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                self.deleteAudio(audio)
            }
            onEnd()
        })
    }
}
