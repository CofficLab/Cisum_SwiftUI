import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func findAudioGroupJob(verbose: Bool = true) {
        if Self.findDuplicatesJobProcessing {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)findDuplicatesJob is running")
            }
            return
        }

        Self.findDuplicatesJobProcessing = true
        Self.shouldStopJob = false

        Task.detached(priority: .background, operation: {
            let total = try? ModelContext(self.modelContainer).fetchCount(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.group == nil
            }))
            
            self.printRunTime("findAudioGroupJob with total=\(total)", tolerance: 2) {
                do {
                    let context = ModelContext(self.modelContainer)
                    try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                        $0.group == nil
                    }), block: { audio in
                        if Self.shouldStopJob {
                            return
                        }

                        if verbose {
                            os_log("\(Logger.isMain)\(Self.label)findAudioGroupJob -> \(audio.title)")
                        }
                        audio.fileHash = audio.getHash()
                        audio.group = AudioGroup(title: audio.fileHash == "" ? "" : audio.title, hash: audio.fileHash)
                    })
                    try context.save()
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            }
        })
    }
}
