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
    
    // MARK: 不存在才insert
    
    nonisolated func insertAudioIfNotExists(_ audio: Audio) {
        let context = ModelContext(modelContainer)
        
        if (Self.findAudio(context: context, audio.url) != nil) {
            return
        }
        
        self.insertAudio(audio)
    }
    
    // MARK: 覆盖式插入
    
    /// 用新的覆盖现有的
    nonisolated func overrideAudios(_ audios: [Audio]) {
        if DB.verbose {
            os_log("\(Logger.isMain)\(DB.label)overrideAudios with count=\(audios.count)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
        let total = audios.count
        for (index, audio) in audios.enumerated() {
            context.insert(audio)
            
            if DB.verbose {
                os_log("\(Logger.isMain)\(DB.label)InsertAudios \(index+1)/\(total)")
            }
            
            Task {
                await self.eventManager.emitSyncing(total, current: index+1)
            }
        }
        
        do {
            try context.save()
            Task {
                // 处理Duplicate逻辑
                //await self.findDuplicatesJob()
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        // 因为进度是异步发出的，接收方可能先接收了20/20，后接收了19/20，一直处于等待状态
        Task {
            await self.eventManager.emitSyncing(total, current: total)
        }
    }
    
    // MARK: 存在则忽略插入
    
    nonisolated func insertAudios(_ audios: [Audio]) {
        let startTime = DispatchTime.now()
        
        if DB.verbose {
            os_log("\(Logger.isMain)\(DB.label)InsertAudios with count=\(audios.count)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        // 如果url属性为unique，数据库已存在相同url的记录，再执行context.insert，发现已存在的被替换成新的了
        // 但在这里，希望如果存在，就不要插入
        let total = audios.count
        for (index, audio) in audios.enumerated() {
            if Self.findAudio(context: context, audio.url) == nil {
                context.insert(audio)
                
                if DB.verbose {
                    os_log("\(Logger.isMain)\(DB.label)InsertAudios \(index+1)/\(total)")
                }
                
                Task {
                    await self.eventManager.emitSyncing(total, current: index+1)
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
                os_log("\(Logger.isMain)\(DB.label)InsertAudios with count=\(total) 🎉🎉🎉 cost \(timeInterval) 秒")
            }
            
            Task {
                // 处理Duplicate逻辑
                //await self.findDuplicatesJob()
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        // 因为进度是异步发出的，接收方可能先接收了20/20，后接收了19/20，一直处于等待状态
        Task {
            await self.eventManager.emitSyncing(total, current: total)
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
                
                Task {
                    await self.eventManager.emitSyncing(total, current: index+1)
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
}
