import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func runFindAudioGroupJob() {
        self.runJob("GroupingJob 🌾🌾🌾", verbose: true, descriptor: Audio.descriptorNoGroup, code: { audio,onEnd in
            Task {
                self.updateGroup(audio)
                onEnd()
            }
        })
    }
}
