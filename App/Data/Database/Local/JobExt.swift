import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    // MARK: 运行任务

//    func runJob(
//        _ id: String,
//        verbose: Bool = false,
//        descriptor: FetchDescriptor<Audio>,
//        qos: DispatchQoS = .background,
//        printLog: Bool = true,
//        printStartLog: Bool = false,
//        printQueueEnter: Bool = false,
//        printLogStep: Int = 100,
//        printCost: Bool = false,
//        concurrency: Bool = true,
//        code: @escaping (_ audio: Audio, _ onEnd: @escaping () -> Void) -> Void,
//        complete: (@escaping (_ context: ModelContext) -> Void) = { _ in }
//    ) {
//        let startTime = DispatchTime.now()
//        let title = "🐎🐎🐎 \(id)"
//        let jobQueue = DispatchQueue(label: "DBJob", qos: qos)
//        let opQueue = OperationQueue()
//        let notifyQueue = DispatchQueue(label: "DBJobNotify", qos: .background)
//        let group = DispatchGroup()
//        var totalCount = 0
//        // 创建一个串行队列
//        let serialQueue = DispatchQueue(label: "com.example.serialQueue")
//
//        do {
//            totalCount = try context.fetchCount(descriptor)
//
//            if totalCount == 0 {
//                os_log("\(Self.label)\(title) All done 🎉🎉🎉")
//                return
//            }
//        } catch let e {
//            os_log(.error, "\(e.localizedDescription)")
//        }
//
//        if printStartLog {
//            os_log("\(Logger.isMain)\(DB.label)\(title) Start 🚀🚀🚀 with count=\(totalCount)")
//        }
//
//        do {
//            let t = totalCount
//            var finishedCount = 0
//            try context.enumerate(descriptor, batchSize: 1, block: { audio in
//                if concurrency {
//                    // MARK: 并发处理
//                    
//                    jobQueue.sync {
//                        group.enter()
//                        if printQueueEnter {
//                            os_log("\(Logger.isMain)\(DB.label)\(title) 已加入队列 \(audio.title), 队列积累任务数量 \(group.count)/\(t)")
//                        }
//
//                        opQueue.addOperation {
//                            code(audio) {
//                                group.leave()
//                                if group.count % printLogStep == 0 && printLog && group.count > 0 {
//                                    os_log("\(Logger.isMain)\(DB.label)\(title) 余 \(group.count)/\(t)")
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    // MARK: 串行处理
//                    
//                    if printQueueEnter {
//                        os_log("\(Logger.isMain)\(DB.label)\(title) 处理 \(audio.title)")
//                    }
//                    
//                    serialQueue.sync {
//                        code(audio) {
//                            finishedCount += 1
//                            if finishedCount % printLogStep == 0 && printLog && finishedCount > 0 {
//                                os_log("\(Logger.isMain)\(DB.label)\(title) 完成 \(finishedCount)/\(t) 🐎🐎🐎")
//                            }
//                        }
//                    }
//                }
//            })
//            
//            group.notify(queue: notifyQueue) {
//                complete(self.context)
//                if printCost {
//                    // 计算代码执行时间
//                    let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
//                    let timeInterval = Double(nanoTime) / 1000000000
//                    os_log("\(Logger.isMain)\(DB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
//                }
//            }
//        } catch let e {
//            os_log(.error, "\(e.localizedDescription)")
//        }
//    }
}

extension DispatchGroup {
    var count: Int {
        debugDescription.components(separatedBy: ",").filter { $0.contains("count") }.first?.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }.first ?? 0
    }
}
