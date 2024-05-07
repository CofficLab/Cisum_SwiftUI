import Foundation
import OSLog

extension DB {
    func findDuplicatesJob() async {
        Task.detached(priority: .background, operation: {
            var i = 0
            while true {
                if await self.verbose {
                    //os_log("\(Logger.isMain)\(Self.label)findDuplicatesJob -> 检查第 \(i) 个")
                }

                if let audio = await self.get(i) {
                    self.updateDuplicatedOf(audio)
                    i += 1
                } else {
                    return
                }
            }
        })
    }
}
