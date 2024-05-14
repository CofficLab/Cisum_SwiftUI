import Foundation
import OSLog
import SwiftData

extension DB {
    func runGetCoversJob() {
        self.runJob("GetCoversJob 🌽🌽🌽", verbose: true, predicate: #Predicate<Audio> {
            $0.hasCover == nil
        }, code: { audio in
            audio.getCoverFromMeta { url in
                self.updateCover(audio, hasCover: url != nil)
            }
        })
    }
}
