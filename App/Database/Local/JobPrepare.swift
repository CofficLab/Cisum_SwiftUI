import Foundation
import OSLog
import SwiftData

extension DB {
    func prepareJob() {
        self.runJob(
            "Download ⏬⏬⏬",
            descriptor: Audio.descriptorFirst,
            printLog: false,
            code: { audio, onEnd in
                self.downloadNextBatch(audio, reason: "\(Logger.isMain)\(Self.label)prepare")
                onEnd()
            })
    }
}
