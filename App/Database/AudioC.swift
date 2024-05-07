import Foundation
import OSLog

// MARK: 增加

extension DB {
    func insertAudio(_ audio: Audio) {
        context.insert(audio)
        
        do {
            try context.save()
            updateDuplicatedOf(audio)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func insertIfNotIn(_ urls: [URL]) {
        for url in urls {
            if getAllURLs().contains(url) == false {
                insertAudio(Audio(url))
            }
        }
    }
    
    func copyTo(_ url: URL) throws {
        try self.disk.copyTo(url: url)
    }
}
