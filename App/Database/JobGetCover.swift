import Foundation
import OSLog
import SwiftData

extension DB {
    func stopGetCoverJob() {
        Self.shouldStopGetCoverJob = true
    }

    func getCoversJob(verbose: Bool = true) {
        if Self.getCoverProcessing {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)GetCoversJob is running 👷👷👷")
            }
            return
        }

        Self.getCoverProcessing = true
        Self.shouldStopGetCoverJob = false
        
        do {
            Self.getCoverTotal = try context.fetchCount(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.hasCover == nil
            }))
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return
        }
        
        if Self.getCoverTotal == 0 {
            os_log("\(self.label)GetCoversJob 🌾🌾🌾 All done 🎉🎉🎉")
            Self.grouping = false
            return
        }
        
        Task.detached(priority: .low) {
            let context = ModelContext(self.modelContainer)
            self.printRunTime("GetCoverJob 🌽🌽🌽", verbose: true) {
                do {
                    try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                        $0.hasCover == nil
                    }), block: { audio in
                        if Self.shouldStopGetCoverJob {
                            return
                        }
                        
                        if audio.isDownloaded {
                            audio.getCoverFromMeta({
                                audio.hasCover = $0 != nil
                            })
                        }
                    })

                    try context.save()
                } catch let error {
                    os_log(.error, "\(error.localizedDescription)")
                }
                
                Self.getCoverProcessing = false
            }
        }
    }
}
