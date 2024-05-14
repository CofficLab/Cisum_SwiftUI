import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
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
    
    func runJob(_ id: String, verbose: Bool = true, code: @escaping () -> Void) {
        if Self.runnningJobs.contains(id) {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)\(id) is running 👷👷👷")
            }
            return
        }

        Self.runnningJobs.insert(id)
        Self.shouldStopJobs.remove(id)

        Task.detached(priority: .low) {
            self.printRunTime(id, tolerance: 2, verbose: true) {
                code()
            }
                
            Self.runnningJobs.remove(id)
            os_log("\(Logger.isMain)\(DB.label)\(id) done 🎉🎉🎉")
        }
    }
}
