import Foundation
import OSLog
import SwiftData

extension DB {
    func runGetCoversJob() {
        runJob("GetCover 🌽🌽🌽", qos: .userInteractive, code: { audio in
            let url = audio.url

            do {
                if try self.context.fetchCount(FetchDescriptor(predicate: #Predicate<Cover> {
                    $0.audio == url
                })) == 0 {
                    if audio.isDownloaded {
                        audio.getCoverFromMeta({ url in
                            if url != nil {
                                self.emitCoverUpdated(audio)
                                self.insertCover(audio)
                            }
                        }, queue: DispatchQueue.global())
                    }
                }
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        })
    }
    
    func emitCoverUpdated(_ audio: Audio) {
        DispatchQueue.main.async {
            EventManager().emitAudioUpdate(audio)
        }
    }
    
    func insertCover(_ audio: Audio) {
        let context = ModelContext(self.modelContainer)
        context.insert(Cover(audio: audio, hasCover: true))
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
