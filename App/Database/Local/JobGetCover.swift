import Foundation
import OSLog
import SwiftData

extension DB {
    func runGetCoversJob() {
        runJob(
            "GetCover 🌽🌽🌽",
            descriptor: Audio.descriptorAll,
            qos: .userInteractive,
            printLog: false,
            printStartLog: false,
            printLogStep: 500,
            concurrency: false,
            code: { audio, onEnd in
                if self.hasCoverRecord(audio) == false {
                    audio.getCoverFromMeta({ url in
                        if url != nil {
                            self.emitCoverUpdated(audio)
                            self.insertCover(audio)
                        }
                    }, queue: DispatchQueue.global())
                }

                onEnd()
            })
    }

    func emitCoverUpdated(_ audio: Audio) {
        DispatchQueue.main.async {
            os_log("\(Logger.isMain)\(Self.label) -> \(audio.title) CoverUpdated 🍋🍋🍋")
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

    func hasCoverRecord(_ audio: Audio) -> Bool {
        let url = audio.url

        do {
            return try self.context.fetchCount(FetchDescriptor(predicate: #Predicate<Cover> {
                $0.audio == url
            })) > 0
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            return false
        }
    }
}
