import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func runFindAudioGroupJob() {
        self.runJob("GroupingJob 🌾🌾🌾", verbose: true, predicate: #Predicate<Audio> {
            $0.group == nil
        }, code: { audio in
            self.updateGroup(audio)
        })
    }
}
