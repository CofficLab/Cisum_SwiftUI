import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    var groupingJobId: String {
        "GroupingJob 🌾🌾🌾"
    }
    
    func runFindAudioGroupJob() {
        let id = groupingJobId
        self.runJob(id, verbose: true, code: {
            if self.getGroupingTaskCount() == 0 {
                os_log("\(self.label)\(id) All done 🎉🎉🎉")
                return
            }
            
            do {
                try self.context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.group == nil
                }), block: { audio in
                    if self.shouldStopJob(id) {
                        return
                    }

                    // 每隔一段时间输出1条日志，避免过多
                    if self.getLastPrintTime(id).distance(to: .now) > 10 {
                        os_log("\(Self.label)UpdateAudioGroup 🌾🌾🌾 left -> \(self.getGroupingTaskCount())")
                        self.updateLastPrintTime(id)
                    }
                        
                    self.updateGroup(audio)
                })
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        })
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
    
    nonisolated func getGroupingTaskCount() -> Int {
        do {
            let total = try ModelContext(self.modelContainer).fetchCount(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.group == nil
            }))
            
            return total
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return 0
        }
    }
}
