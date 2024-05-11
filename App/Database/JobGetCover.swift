import Foundation
import OSLog
import SwiftData

extension DB {
    func getCovers() {
        Task.detached(priority: .low) {
            let context = ModelContext(self.modelContainer)
            do {
                try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.hasCover == nil
                }), block: { audio in
                    if audio.isDownloaded {
                        audio.getCoverFromMeta({
                            audio.hasCover = $0 != nil
                        })
                    }
                })
                try context.save()
            } catch let error {
                os_log(.error, "\(error.localizedDescription)")
            }
        }
    }
}
