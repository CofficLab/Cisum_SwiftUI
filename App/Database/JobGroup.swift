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

    nonisolated func updateGroup(_ audio: Audio) {
        let fileHash = audio.getHash()
        if fileHash.isEmpty {
            return
        }

        let context = ModelContext(self.modelContainer)
        guard let dbAudio = context.model(for: audio.id) as? Audio else {
            return
        }

        dbAudio.group = AudioGroup(title: audio.title, hash: fileHash)

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
