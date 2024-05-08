import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func findDuplicatesJob() {
        let context = ModelContext(self.modelContainer)
        let total = Self.getTotal(context: context)
        let group = DispatchGroup()

        for i in 1 ... total {
            Task.detached(priority: .background, operation: {
                group.enter()
                if DB.verbose {
                    os_log("\(Logger.isMain)\(Self.label)updateFileHashJob -> 检查第 \(i)/\(total) 个")
                }

                if let audio = self.get(i) {
                    self.updateFileHash(audio, hash: audio.getHash())
                }

                group.leave()
            })
        }

        // 等待所有任务完成
        group.notify(queue: .main) {
            for i in 1 ... total {
                if DB.verbose {
                    os_log("\(Logger.isMain)\(Self.label)findDuplicatesJob -> 检查第 \(i)/\(total) 个")
                }

                if let audio = self.get(i - 1) {
                    self.updateDuplicatedOf(audio)
                }
            }
        }
    }
}
