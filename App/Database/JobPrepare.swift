import Foundation
import SwiftData
import OSLog

extension DB {
    func prepareJob() {
        var descriptor = Audio.descriptorAll
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        
        self.runJob("PrepareJob ⏬⏬⏬", descriptor: descriptor, code: { audio,onEnd  in
            self.downloadNextBatch(audio, reason: "\(Logger.isMain)\(Self.label)prepare")
            onEnd()
        })
    }
}
