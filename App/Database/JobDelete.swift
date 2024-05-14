import Foundation
import OSLog

extension DB {
    func runDeleteInvalidJob() {
        self.runJob("DeleteInvalid 🗑️🗑️🗑️", verbose: true, predicate: #Predicate<Audio> {
            $0.title != ""
        }, code: { audio in
            if !FileManager.default.fileExists(atPath: audio.url.path) {
                os_log(.error, "\(self.label)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                self.deleteAudio(audio)
            }
        })
    }
}
