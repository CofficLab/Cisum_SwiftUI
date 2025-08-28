import Foundation
import OSLog
import SwiftData
import MagicCore
import SwiftUI

extension AudioDB {
    func prepareJob() async throws {
        os_log("\(self.t) 🚀🚀🚀 Prepare")

        let audio = try firstAudio()

        if let audio = audio {
            try await self.downloadNextBatch(audio, reason: "\(self.t)prepare")
        }
    }
}

extension AudioDB {
    func updateGroupForURLs(_ urls: [URL], verbose: Bool = true) {
        let total = urls.count
        let title = "\(t) UpdateHash(\(total))"
        let startTime = DispatchTime.now()

        if verbose {
            os_log("\(title) 🚀🚀🚀")
        }

        for (i, url) in urls.enumerated() {
            if verbose && (i + 1) % 100 == 0 {
                os_log("\(self.t) UpdateHash \(i + 1)/\(total) -> \(url.lastPathComponent)")
            }

            guard url.isDownloaded, let audio = findAudio(url) else {
                continue
            }

            updateHash(audio)
        }

        if verbose {
            os_log("\(self.jobEnd(startTime, title: title))")
        }
    }
}

extension AudioDB {
    var labelForDelete: String { "\(t)🗑️🗑️🗑️" }

    func runDeleteInvalidJob() throws {
        os_log("\(self.t)🚀🚀🚀")

        do {
            try context.enumerate(AudioModel.descriptorAll, block: { audio in
                if !FileManager.default.fileExists(atPath: audio.url.path) {
                    os_log(.error, "\(self.t)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                    try self.deleteAudio(audio, verbose: true)
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

extension AudioDB {
    // MARK: 运行任务

    func runJob(
        _ id: String,
        verbose: Bool = false,
        descriptor: FetchDescriptor<AudioModel>,
        qos: DispatchQoS = .background,
        printLog: Bool = true,
        printStartLog: Bool = false,
        printQueueEnter: Bool = false,
        printLogStep: Int = 100,
        printCost: Bool = false,
        concurrency: Bool = true,
        code: @escaping (_ audio: AudioModel, _ onEnd: @escaping () -> Void) -> Void,
        complete: (@escaping (_ context: ModelContext) -> Void) = { _ in }
    ) {
        let startTime = DispatchTime.now()
        let title = "🐎🐎🐎 \(id)"
        let jobQueue = DispatchQueue(label: "DBJob", qos: qos)
        let opQueue = OperationQueue()
        let notifyQueue = DispatchQueue(label: "DBJobNotify", qos: .background)
        let group = DispatchGroup()
        var totalCount = 0
        // 创建一个串行队列
        let serialQueue = DispatchQueue(label: "com.example.serialQueue")

        do {
            totalCount = try context.fetchCount(descriptor)

            if totalCount == 0 {
                os_log("\(Self.t)\(title) All done 🎉🎉🎉")
                return
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        if printStartLog {
            os_log("\(self.t)\(title) Start 🚀🚀🚀 with count=\(totalCount)")
        }

        do {
            let t = totalCount
            var finishedCount = 0
            try context.enumerate(descriptor, batchSize: 1, block: { audio in
                if concurrency {
                    // MARK: 并发处理

                    jobQueue.sync {
                        group.enter()
                        if printQueueEnter {
                            os_log("\(t)\(title) 已加入队列 \(audio.title), 队列积累任务数量 \(group.count)/\(t)")
                        }

                        opQueue.addOperation {
                            code(audio) {
                                group.leave()
                                if group.count % printLogStep == 0 && printLog && group.count > 0 {
                                    os_log("\(t)\(title) 余 \(group.count)/\(t)")
                                }
                            }
                        }
                    }
                } else {
                    // MARK: 串行处理

                    if printQueueEnter {
                        os_log("\(t)\(title) 处理 \(audio.title)")
                    }

                    serialQueue.sync {
                        code(audio) {
                            finishedCount += 1
                            if finishedCount % printLogStep == 0 && printLog && finishedCount > 0 {
                                os_log("\(t)\(title) 完成 \(finishedCount)/\(t) 🐎🐎🐎")
                            }
                        }
                    }
                }
            })

            group.notify(queue: notifyQueue) {
                complete(self.context)
                if printCost {
                    // 计算代码执行时间
                    let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
                    let timeInterval = Double(nanoTime) / 1000000000
                    os_log("\(self.t)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

extension DispatchGroup {
    var count: Int {
        debugDescription.components(separatedBy: ",").filter { $0.contains("count") }.first?.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }.first ?? 0
    }
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 1200)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 1200)
    .frame(height: 1200)
}
