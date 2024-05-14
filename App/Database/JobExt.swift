import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    // MARK: 运行任务

    func runBackgroundJob() {
        Task.detached(priority: .background, operation: {
            await self.runGetCoversJob()
            await self.runFindAudioGroupJob()
            await self.runDeleteInvalidJob()
        })
    }

    // MARK: Start and Stop

    static func stopAllJobs() {
        shouldStopAllJobs = true
    }

    static func canRunJobs() {
        shouldStopAllJobs = false
    }

    func stopJob(_ id: String) {
        Self.shouldStopJobs.insert(id)
    }

    static func shouldStopJob(_ id: String) -> Bool {
        shouldStopAllJobs || shouldStopJobs.contains(id)
    }

    func isJobRunning(_ id: String) -> Bool {
        Self.runnningJobs.contains(id)
    }

    // MARK: 运行任务

    func runJob(_ id: String, verbose: Bool = true, predicate: Predicate<Audio>, code: @escaping (_ audio: Audio) -> Void) {
        if Self.runnningJobs.contains(id) {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)🐎🐎🐎\(id) is running 👷👷👷")
            }
            return
        }

        Self.runnningJobs.insert(id)
        Self.shouldStopJobs.remove(id)
        let context = ModelContext(modelContainer)
        let startTime = DispatchTime.now()
        let title = "🐎🐎🐎\(id)"
        let jobQueue = DispatchQueue(label: "DBJob", qos: .background)
        let notifyQueue = DispatchQueue.global()
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
                jobQueue.async(group: group) {
                    if Self.shouldStopJob(id) {
                        Self.runnningJobs.remove(id)
                        return
                    } else {
                        code(audio)
                    }
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        group.notify(queue: notifyQueue) {
            Self.runnningJobs.remove(id)

            // 计算代码执行时间
            let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1000000000

            if DB.verbose && timeInterval > 3 {
                os_log("\(Logger.isMain)\(DB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
            }
        }
    }
}
