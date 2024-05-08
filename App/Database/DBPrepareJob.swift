import Foundation
import OSLog

extension DB {
    func prepareJob() {
        Task.detached(operation: {
            guard let first = self.get(0) else {
                return
            }
            
            os_log("\(Logger.isMain)\(Self.label)Run Prepare Job")
            
            self.downloadNext(first, reason: "\(Logger.isMain)\(Self.label)prepare")
        })
    }
}
