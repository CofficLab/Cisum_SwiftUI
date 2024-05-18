import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func runFindAudioGroupJob() {
        self.runJob("GroupingJob 🌾🌾🌾", verbose: false, descriptor: Audio.descriptorNoGroup, code: { audio, onEnd in
            self.updateGroup(audio)
            
            onEnd()
        }, complete: { context in
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        })
    }
}
