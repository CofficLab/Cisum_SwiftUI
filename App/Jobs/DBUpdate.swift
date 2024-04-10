import Foundation
import OSLog

actor DBUpdate {
    var db: DB
    var queue = DispatchQueue.global(qos: .background)
    
    init(db: DB) {
        self.db = db
    }
    
    func run(_ items: [MetadataItemWrapper]) {
        Task.detached {
            os_log("\(Logger.isMain)🍋 DBUpdate::run with count=\(items.count)")
            for item in items {
                if var current = await self.db.find(item.url!) {
                    if item.isDeleted {
                        await self.db.delete(current)
                        continue
                    }
                    
                    // os_log("\(Logger.isMain)🍋 DB::更新 \(current.title)")
                    current = current.mergeWith(item)
                } else {
                    if item.isDeleted {
                        continue
                    }
                    
                    // os_log("\(Logger.isMain)🍋 DB::插入")
                    if let audio = Audio.fromMetaItem(item) {
                        await self.db.insert(audio)
                    }
                }
            }

            if await self.db.hasChanges() {
                os_log("\(Logger.isMain)🍋 DB::保存")
                await self.db.save()
            } else {
                os_log("\(Logger.isMain)🍋 DB::upsert nothing changed 👌")
            }
        }
    }
}
