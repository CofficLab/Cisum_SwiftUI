import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    func insertAudio(_ audio: Audio, force: Bool = false) {
        if force == false && (findAudio(audio.url) != nil) {
            return
        }
        
        context.insert(audio)
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        updateGroup(audio)
    }
}
