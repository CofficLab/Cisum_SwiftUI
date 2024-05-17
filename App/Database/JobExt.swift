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
        printLog: Bool = true,
        printLogStep: Int = 100,
        code: @escaping (_ audio: Audio, _ onEnd: @escaping () -> Void) -> Void,
        complete: (@escaping (_ context: ModelContext) -> Void) = { _ in }
    ) {
        let startTime = DispatchTime.now()
        let title = "🐎🐎🐎\(id)"
        let jobQueue = DispatchQueue(label: "DBJob", qos: qos)
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 2
        let notifyQueue = DispatchQueue(label: "DBJobNotify", qos: .background)
        let group = DispatchGroup()
        var totalCount = 0

        do {
            totalCount = try context.fetchCount(descriptor)

            if totalCount == 0 {
                os_log("\(Self.label)\(title) All done 🎉🎉🎉")
                return
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        os_log("\(Logger.isMain)\(DB.label)\(title) Start 🚀🚀🚀")

        do {
            let t = totalCount
            try context.enumerate(descriptor, block: { audio in
                jobQueue.sync {
                    group.enter()
                    opQueue.addOperation {
                        code(audio) {
                            group.leave()
                            if group.count % printLogStep == 0 && printLog {
                                os_log("\(Logger.isMain)\(DB.label)\(title) 余 \(group.count)/\(t)")
                            }
                        }
                    }
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        group.notify(queue: notifyQueue) {
            complete(self.context)
            if verbose {
                // 计算代码执行时间
                let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
                let timeInterval = Double(nanoTime) / 1000000000
                os_log("\(Logger.isMain)\(DB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
            }
        }
    }
}

extension DispatchGroup {
    var count: Int {
        self.debugDescription.components(separatedBy: ",").filter { $0.contains("count") }.first?.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }.first ?? 0
    }
}
