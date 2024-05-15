import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    // MARK: 运行任务

    func runJob(
        _ id: String,
        verbose: Bool = true,
        predicate: Predicate<Audio>? = nil,
        qos: DispatchQoS = .background,
        code: @escaping (_ audio: Audio) -> Void)
    {
        let startTime = DispatchTime.now()
        let title = "🐎🐎🐎\(id)"
        let jobQueue = DispatchQueue(label: "DBJob", qos: qos)
        let notifyQueue = DispatchQueue(label: "DBJobNotify", qos: .background)
        let group = DispatchGroup()

        do {
            let total = try context.fetchCount(FetchDescriptor(predicate: predicate))

            if total == 0 {
                os_log("\(Self.label)\(title) All done 🎉🎉🎉")
                return
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        os_log("\(Logger.isMain)\(DB.label)\(title) Start 🚀🚀🚀")

        do {
            try context.enumerate(FetchDescriptor(predicate: predicate), block: { audio in
                jobQueue.sync {
                    group.enter()
                    code(audio)
                    group.leave()
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        group.notify(queue: notifyQueue) {
            do {
                try self.context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
            
            if verbose{
                // 计算代码执行时间
                let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
                let timeInterval = Double(nanoTime) / 1000000000
                os_log("\(Logger.isMain)\(DB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
            }
        }
    }
}
