import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    // MARK: 运行任务

    func runJob(
        _ id: String,
        verbose: Bool = true,
        descriptor: FetchDescriptor<Audio>,
        qos: DispatchQoS = .background,
        code: @escaping (_ audio: Audio, _ onEnd:@escaping () -> Void) -> Void)
    {
        let startTime = DispatchTime.now()
        let title = "🐎🐎🐎\(id)"
        let jobQueue = DispatchQueue(label: "DBJob", qos: qos)
        let notifyQueue = DispatchQueue(label: "DBJobNotify", qos: .background)
        let group = DispatchGroup()
        var groupCount = 0
        var total = 0

        do {
            total = try context.fetchCount(descriptor)

            if total == 0 {
                os_log("\(Self.label)\(title) All done 🎉🎉🎉")
                return
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        os_log("\(Logger.isMain)\(DB.label)\(title) Start 🚀🚀🚀")

        do {
            try context.enumerate(descriptor, block: { audio in
                jobQueue.sync {
                    group.enter()
                    groupCount = groupCount + 1
                    code(audio, {
                        print("leave \(audio.title) -> \(groupCount)/\(total)")
                        group.leave()
                        groupCount = groupCount - 1
                    })
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        group.notify(queue: notifyQueue) {
            if verbose {
                // 计算代码执行时间
                let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
                let timeInterval = Double(nanoTime) / 1000000000
                os_log("\(Logger.isMain)\(DB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
            }
        }
    }
}
