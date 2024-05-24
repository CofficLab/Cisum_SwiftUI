import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func runFindAudioGroupJob() {
        runJob(
            "GetGroup 🌾🌾🌾",
            verbose: true,
            descriptor: Audio.descriptorNoGroup,
            printLog: true,
            printStartLog: true,
            printQueueEnter: false,
            printLogStep: 100,
            printCost: true,
            code: { audio, onEnd in
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
