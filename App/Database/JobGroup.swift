import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func runFindAudioGroupJob() {
        self.runJob("GroupingJob 🌾🌾🌾", verbose: true, descriptor: Audio.descriptorNoGroup, code: { audio,onEnd in
            Task {
                let fileHash = audio.getHash()
                if fileHash.isEmpty {
                    return onEnd()
                }
                
                audio.group = AudioGroup(title: audio.title, hash: fileHash)
                
                onEnd()
            }
        }, complete: { context in
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        })
    }
}
