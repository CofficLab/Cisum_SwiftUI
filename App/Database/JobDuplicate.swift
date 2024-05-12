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

        let group = DispatchGroup()
        let total = getTotal()

        Task.detached(priority: .background, operation: {
            self.printRunTime("updateFileHashJob with total=\(total)", tolerance: 2) {
                do {
                    let context = ModelContext(self.modelContainer)
                    try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                        $0.fileHash == ""
                    }), block: { audio in
                        if Self.shouldStopJob {
                            if verbose {
                                // os_log("\(Logger.isMain)\(Self.label)updateFileHashJob -> Stop 🤚🤚🤚")
                            }
                            return
                        }

//                        if verbose {
//                            os_log("\(Logger.isMain)\(Self.label)updateFileHashJob -> \(audio.title)")
//                        }

                        group.enter()
                        self.updateFileHash(audio)
                        group.leave()
                    })
                    try context.save()
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            }
        })

        // 等待所有UpdateFileHash任务完成
        group.notify(queue: .main) {
            Task.detached(priority: .low) {
                self.printRunTime("updateDuplicatedOf with total=\(total)", tolerance: 3) {
                    do {
                        let context = ModelContext(self.modelContainer)
                        try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                            $0.title != ""
                        }), block: {
                            if Self.shouldStopJob {
                                return
                            }
                            
                            os_log("updateDuplicatedOf \($0.title)")
                            self.updateDuplicatedOf($0)
                        })
                        try context.save()

                        Self.findDuplicatesJobProcessing = false
                    } catch let error {
                        os_log(.error, "\(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
