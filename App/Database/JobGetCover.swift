import Foundation
import OSLog
import SwiftData

extension DB {
    var getCoversJobId: String {
        "GetCoversJob 🌽🌽🌽"
    }
    
    func runGetCoversJob() {
        let id = self.getCoversJobId
        self.runJob(id, verbose: true, code: {
            if self.getCoverTaskCount() == 0 {
                os_log("\(self.label)\(id) All done 🎉🎉🎉")
                return
            }
            
            let context = ModelContext(self.modelContainer)
            do {
                try context.enumerate(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.hasCover == nil
                }), block: { audio in
                    if self.shouldStopJob(id) {
                        //os_log("\(Self.label)\(id) ShouldStop")
                        return
                    }
                            
                    audio.getCoverFromMeta { url in
                        self.updateCover(audio, hasCover: url != nil)
                    }
                        
                    // 每隔一段时间输出1条日志，避免过多
                    if self.getLastPrintTime(id).distance(to: .now) > 5 {
                        self.updateLastPrintTime(id)
                        os_log("\(Self.label)\(id) left -> \(self.getCoverTaskCount())")
                    }
                })
            } catch {
                os_log(.error, "\(error.localizedDescription)")
            }
        })
    }
    
    nonisolated func getCoverTaskCount() -> Int {
        do {
            let total = try ModelContext(self.modelContainer).fetchCount(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.hasCover == nil
            }))
            
            return total
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return 0
        }
    }
}
