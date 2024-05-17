import Foundation
import OSLog
import SwiftData

extension DB {
    func prepareJob() {
        var descriptor = Audio.descriptorAll
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1

        self.runJob(
            "PrepareJob ⏬⏬⏬",
            descriptor: descriptor,
            printLog: false,
            code: { audio, onEnd in
                self.downloadNextBatch(audio, reason: "\(Logger.isMain)\(Self.label)prepare")
                onEnd()
            })
    }
}
