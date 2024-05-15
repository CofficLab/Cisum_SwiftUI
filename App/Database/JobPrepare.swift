import Foundation
import OSLog

extension DB {
    func prepareJob() {
        guard let first = self.get(0) else {
            return
        }

        os_log("\(Logger.isMain)\(Self.label)Run Prepare Job")

        self.downloadNextBatch(first, reason: "\(Logger.isMain)\(Self.label)prepare")
    }
}
