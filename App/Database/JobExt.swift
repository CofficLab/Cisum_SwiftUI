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
    
    // MARK: 输出日志
    
    static func updateLastPrintTime(_ id: String) {
        jobLastPrintTime[id] = .now
    }
    
    static func getLastPrintTime(_ id: String) -> Date {
        if let t = jobLastPrintTime[id] {
            return t
        }
        
        return .distantPast
    }
    
    // MARK: 运行任务
    
    func runJob(_ id: String, verbose: Bool = true, predicate: Predicate<Audio>, code: @escaping (_ audio: Audio) -> Void) {
        Task.detached(priority: .background, operation: {
            if Self.runnningJobs.contains(id) {
                if verbose {
                    os_log("\(Logger.isMain)\(Self.label)🐎🐎🐎\(id) is running 👷👷👷")
                }
                return
            }
                
            Self.runnningJobs.insert(id)
            Self.shouldStopJobs.remove(id)
            Self.updateLastPrintTime(id)
            let context = ModelContext(self.modelContainer)
                
            do {
                let total = try context.fetchCount(FetchDescriptor(predicate: predicate))
                    
                if total == 0 {
                    os_log("\(Self.label)🐎🐎🐎\(id) All done 🎉🎉🎉")
                    return
                }
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
                
            self.printRunTime("🐎🐎🐎" + id, tolerance: 0, verbose: true) {
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = 2
                queue.qualityOfService = .utility
                
                do {
                    try context.enumerate(FetchDescriptor(predicate: predicate), block: { audio in
                        queue.addOperation {
                            if Self.shouldStopJob(id) {
                                os_log("\(Self.label)🐎🐎🐎\(id) 取消所有任务 🤚🤚🤚")
                                queue.isSuspended = true
                            } else {
                                self.runJobBlock(audio, id: id, code: code)
                            }
                        }
                    })
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
                    
                queue.waitUntilAllOperationsAreFinished()
                Self.runnningJobs.remove(id)
            }
        })
    }
    
    nonisolated func runJobBlock(_ audio: Audio, id: String, code: (_ audio: Audio) -> Void) {
        if Self.shouldStopJob(id) {
             //os_log("\(Self.label)🐎🐎🐎\(id) Stop 🤚🤚🤚")
        } else {
            code(audio)
            
            // 每隔一段时间输出1条日志，避免过多
            if Self.getLastPrintTime(id).distance(to: .now) > 3 {
                //os_log("\(Self.label)🐎🐎🐎\(id) -> \(audio.title)")
                Self.updateLastPrintTime(id)
            }
        }
    }
}