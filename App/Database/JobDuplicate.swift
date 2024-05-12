import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func stopFindDuplicatedsJob() {
        Self.shouldStopJob = true
        Self.findDuplicatesJobProcessing = false
    }
    
    func findDuplicatesJob(verbose: Bool = true) {
        if Self.findDuplicatesJobProcessing {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)findDuplicatesJob is running")
            }
            return
        }

        Self.findDuplicatesJobProcessing = true
        Self.shouldStopJob = false

        let context = ModelContext(modelContainer)
        let group = DispatchGroup()

        // 如果Task.detached写在for之外，内存占用会越来越大，因为每次循环算Hash都读一个文件进内存，直到Task结束才能释放
        do {
            let audios = try context.fetch(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.fileHash == ""
            }))

            let total = audios.count

            for (i, audio) in audios.enumerated() {
                Task.detached(priority: .low) {
                    if Self.shouldStopJob {
                        if verbose {
                            //os_log("\(Logger.isMain)\(Self.label)updateFileHashJob -> Stop 🤚🤚🤚")
                        }
                        return
                    }
                    
                    if verbose {
                        os_log("\(Logger.isMain)\(Self.label)updateFileHashJob -> \(i)/\(total)")
                    }

                    group.enter()
                    self.updateFileHash(audio)
                    group.leave()
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        // 等待所有UpdateFileHash任务完成
        let total = Self.getTotal(context: context)
        group.notify(queue: .main) {
            Task.detached(priority: .low) {
                for i in 1 ... total {
                    if Self.shouldStopJob {
                        return
                    }
                    
                    if DB.verbose {
                        os_log("\(Logger.isMain)\(Self.label)findDuplicatesJob -> \(i)/\(total)")
                    }

                    self.updateDuplicatedOf(i - 1)
                }

                Self.findDuplicatesJobProcessing = false
            }
        }
    }
}
