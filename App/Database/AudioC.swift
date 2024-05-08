import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    nonisolated func insertAudio(_ audio: Audio) {
        let context = ModelContext(self.modelContainer)
        context.insert(audio)
        
        do {
            try context.save()
            updateDuplicatedOf(audio)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    nonisolated func insertIfNotIn(_ urls: [URL]) {
        if urls.isEmpty {
            return
        }
        
        let allUrls = getAllURLs()
        for url in urls {
            if allUrls.contains(url) == false {
                insertAudio(Audio(url))
            }
        }
    }
    
    func copyTo(_ url: URL) throws {
        try self.disk.copyTo(url: url)
    }
}
