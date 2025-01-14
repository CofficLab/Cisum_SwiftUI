import Foundation
import Combine
import MagicKit

import OSLog

@MainActor
class BookDB: ObservableObject, SuperEvent, SuperLog {
    nonisolated static let emoji = "📖"
    
    private let db: BookRecordDB
    private var disk: URL
    private let verbose: Bool
    private var monitor: Cancellable? = nil
    
    init(disk: URL, verbose: Bool) throws {
        if verbose {
            os_log("\(Self.i)BookDB")
        }

        self.verbose = verbose
        self.db = BookRecordDB(try BookConfig.getContainer(), reason: "BookDB")
        self.disk = disk
        self.monitor = self.makeMonitor()
    }
    
    func getRootBooks() async -> [BookModel] {
        let urls:[URL] = await self.db.getBooks()
        
        return urls.map{BookModel(url: $0)}
    }

    func getRootBookURLs() async -> [URL] {
        await self.db.getBooks()
    }
    
    func getTotal() async -> Int {
        await self.getRootBooks().count
    }
    
    func delete(_ book: BookModel, verbose: Bool) async {
//        try? self.disk.deleteFile(book.url)
//        self.emit(.audioDeleted)
    }
    
    func download(_ book: BookModel, verbose: Bool) async throws {
//        try await self.disk.download(book.url, reason: "BookDB.download", verbose: verbose)
    }
    
    func find(_ url: URL) async -> URL? {
        await self.db.hasBook(url) ? url : nil
    }
    
    func makeMonitor() -> Cancellable {
        self.disk.onDirChange(verbose: true, caller: self.className, onChange: { items, isFirst, error in
            Task {
                os_log("\(self.t)🍋🍋🍋 OnDiskUpdate")
                self.emitDBSyncing(items)
                await self.db.sync(items, verbose: true, isFirst: isFirst)
                self.emitDBSynced()
                os_log("\(self.t)✅✅✅ OnDBSynced")
            }
        })
    }
}

// MARK: Emit

extension BookDB {
    func emitDBSyncing(_ items: [URL]) {
        self.emit(name: .bookDBSyncing, object: self, userInfo: ["items": items])
    }
    
    func emitDBSynced() {
        self.emit(name: .bookDBSynced, object: nil)
    }
}

// MARK: Event

extension Notification.Name {
    static let bookDBSyncing = Notification.Name("bookDBSyncing")
    static let bookDBSynced = Notification.Name("bookDBSynced")
}
