import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    nonisolated func insertAudio(_ audio: Audio) {
        let context = ModelContext(self.modelContainer)
        context.insert(audio)
        
        do {
            try context.save()
//            updateDuplicatedOf(audio)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    nonisolated func insertAudios(_ urls: [URL]) {
        let startTime = DispatchTime.now()
        
        if DB.verbose {
            os_log("\(Logger.isMain)\(DB.label)InsertAudios with count=\(urls.count)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        for url in urls {
            context.insert(Audio(url))
        }
        
        do {
            try context.save()
            
            // 计算代码执行时间
            let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            
            if DB.verbose {
                os_log("\(Logger.isMain)\(DB.label)InsertAudios with count=\(urls.count) 🎉🎉🎉 cost \(timeInterval) 秒")
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    func copyTo(_ url: URL) throws {
        try self.disk.copyTo(url: url)
    }
}
