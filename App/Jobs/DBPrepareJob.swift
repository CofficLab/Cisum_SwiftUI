import Foundation
import OSLog

actor DBPrepareJob {
    var db: DB
    var label = "🧮 DBPrepareJob::"
    
    init(db: DB) {
        self.db = db
    }
    
    func run() {
        Task.detached(operation: {
            await self.prepare()
        })
    }
    
    private func prepare() async {
        guard let first = await db.get(0) else {
            return
        }
        
        await db.downloadNext(first, reason: "\(Logger.isMain)\(self.label)prepare")
    }
}
