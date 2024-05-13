import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    func stopGroupJob() {
        Self.shouldStopJob = true
    }
    
    func findAudioGroupJob(verbose: Bool = true) {
        if Self.grouping {
            if verbose {
                os_log("\(Logger.isMain)\(Self.label)FindAudioGroupJob is running 👷👷👷")
            }
            return
        }

        Self.grouping = true
        Self.shouldStopJob = false
        
        do {
            Self.groupingTotal = try context.fetchCount(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.group == nil
            }))
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return
        }
        
        if Self.groupingTotal == 0 {
            os_log("\(self.label)FindAudioGroupJob 🌾🌾🌾 All done 🎉🎉🎉")
            Self.grouping = false
            return
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 3
        
        self.printRunTime("FindAudioGroupJob 🌾🌾🌾 total=\(Self.groupingTotal)", tolerance: 2, verbose: true) {
            do {
                try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.group == nil
                }), block: { audio in
                    queue.addOperation {
                        if Self.shouldStopJob {
                            return
                        }

                        // 每隔一段时间输出1条日志，避免过多
                        if Self.lastPrintTime.distance(to: .now) > 20 {
                            do {
                                Self.lastPrintTime = .now
                                let leftCount = try ModelContext(self.modelContainer).fetchCount(FetchDescriptor(predicate: #Predicate<Audio> {
                                    $0.group == nil
                                }))
                                os_log("\(Self.label)UpdateAudioGroup 🌾🌾🌾 left -> \(leftCount)")
                            } catch _ {}
                        }
                        
                        self.updateGroup(audio)
                    }
                })
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        }
        
        Self.grouping = false
    }
    
    nonisolated func updateGroup(_ audio: Audio) {
        self.printRunTime("UpdateAudioGroup 🌾🌾🌾 -> \(audio.title) -> \(audio.getFileSizeReadable())", tolerance: 3) {
            let fileHash = audio.getHash()
            if fileHash.isEmpty {
                return
            }
            
            let context = ModelContext(self.modelContainer)
            guard let dbAudio = context.model(for: audio.id) as? Audio else {
                return
            }

            dbAudio.group = AudioGroup(title: audio.title, hash: fileHash)
            
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        }
    }
}
