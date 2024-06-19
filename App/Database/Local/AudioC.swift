import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    func insertAudio(_ audio: Audio, force: Bool = false) {
        if force == false && (findAudio(audio.url) != nil) {
            return
        }
        
        do {
            context.insert(audio)
            try context.save()
            updateGroup(audio)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
