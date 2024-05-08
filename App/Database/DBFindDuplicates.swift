import Foundation
import OSLog
import SwiftData

extension DB {
    nonisolated func updateFileHashJob() {
        let context = ModelContext(self.modelContainer)
        let total = Self.getTotal(context: context)
        for i in 1...total {
            if DB.verbose {
                os_log("\(Logger.isMain)\(Self.label)updateFileHashJob -> 检查第 \(i)/\(total) 个")
            }

            if let audio = self.get(i-1) {
                self.updateFileHash(audio)
            } else {
                return
            }
        }
    }

    func findDuplicatesJob() async {
        Task.detached(priority: .background, operation: {
            self.updateFileHashJob()

            var i = 0
            while true {
                if DB.verbose {
                    os_log("\(Logger.isMain)\(Self.label)findDuplicatesJob -> 检查第 \(i) 个")
                }

                if let audio = self.get(i) {
                    self.updateDuplicatedOf(audio)
                    i += 1
                } else {
                    return
                }
            }
        })
    }
}
