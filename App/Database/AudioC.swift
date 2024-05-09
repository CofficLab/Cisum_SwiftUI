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
            //os_log("\(Logger.isMain)\(DB.label)InsertAudios with count=\(urls.count)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
        // 但在这里，希望如果存在，就不要插入
        let total = urls.count
        for (index, url) in urls.enumerated() {
            if Self.findAudio(context: context, url) == nil {
                context.insert(Audio(url))
                
                if DB.verbose {
                    os_log("\(Logger.isMain)\(DB.label)InsertAudios \(index+1)/\(total)")
                }
            }
        }
        
        if context.hasChanges == false {
            return
        }
        
        do {
            try context.save()
            
            // 计算代码执行时间
            let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            
            if DB.verbose {
                os_log("\(Logger.isMain)\(DB.label)InsertAudios with count=\(urls.count) 🎉🎉🎉 cost \(timeInterval) 秒")
            }
            
            Task {
                // 处理Duplicate逻辑
                //await self.findDuplicatesJob()
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    func copyTo(_ url: URL) throws {
        try self.disk.copyTo(url: url)
    }
}
