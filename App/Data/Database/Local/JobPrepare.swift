import Foundation
import OSLog
import SwiftData

extension DB {
    var labelPrepare: String { "\(self.label)⏬⏬⏬ Prepare" }
    
    func prepareJob() {
        os_log("\(self.labelPrepare) 🚀🚀🚀")
        
        let audio = DB.first(context: context)
        
        if let audio = audio {
            self.downloadNextBatch(audio, reason: "\(Logger.isMain)\(Self.label)prepare")
        }
    }
}
