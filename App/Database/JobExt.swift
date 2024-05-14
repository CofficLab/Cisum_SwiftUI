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
    
    nonisolated func stopAllJobs() {
        Self.shouldStopAllJobs = true
    }
    
    nonisolated func canRunJobs() {
        Self.shouldStopAllJobs = false
    }
    
    func stopJob(_ id: String) {
        Self.shouldStopJobs.insert(id)
    }
    
    nonisolated func shouldStopJob(_ id: String) -> Bool {
        Self.shouldStopAllJobs || Self.shouldStopJobs.contains(id)
    }
    
    func isJobRunning(_ id: String) -> Bool {
        Self.runnningJobs.contains(id)
    }
    
    // MARK: 输出日志
    
    nonisolated func updateLastPrintTime(_ id: String) {
        Self.jobLastPrintTime[id] = .now
    }
    
    nonisolated func getLastPrintTime(_ id: String) -> Date {
        if let t = Self.jobLastPrintTime[id] {
            return t
        }
        
        return .distantPast
    }
    
    func runJob(_ id: String, verbose: Bool = true, predicate: Predicate<Audio>, code: @escaping (_ audio: Audio) -> Void) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 2
        queue.qualityOfService = .utility
        
        queue.addOperation {
            if Self.runnningJobs.contains(id) {
                if verbose {
                    os_log("\(Logger.isMain)\(Self.label)🐎🐎🐎\(id) is running 👷👷👷")
                }
                return
            }

            Self.runnningJobs.insert(id)
            Self.shouldStopJobs.remove(id)
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
            
            self.printRunTime("🐎🐎🐎" + id, tolerance: 2, verbose: true) {
                self.updateLastPrintTime(id)
                do {
                    try context.enumerate(FetchDescriptor(predicate: predicate), block: { audio in
                        if self.shouldStopJob(id) {
                            return
                        }
                        
                        code(audio)
                        
                        // 每隔一段时间输出1条日志，避免过多
                        if self.getLastPrintTime(id).distance(to: .now) > 10 {
                            os_log("\(Self.label)🐎🐎🐎\(id) -> \(audio.title)")
                            self.updateLastPrintTime(id)
                        }
                    })
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            }
                
            Self.runnningJobs.remove(id)
        }
    }
}
