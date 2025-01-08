import Foundation
import MagicKit
import MagicUI
import OSLog

class BookDB: ObservableObject, SuperEvent, SuperLog {
    static let emoji = "📖"
    
    var db: BookRecordDB
    var disk: URL
    let worker: BookWorker
    
    init(db: BookRecordDB, disk: URL, verbose: Bool) {
        if verbose {
            os_log("\(Self.i)BookDB")
        }

        self.db = db
        self.disk = disk
        self.worker = BookWorker(db: db)

//        Task {
//            self.worker.runJobs()
//            await disk.watch(reason: "AudioDB.init", verbose: true)
//        }
    }

    func getRootBooks() async -> [Book] {
        []
//        (await self.db.getBooksOfCollectionType()).map { book in
//            book.setDB(self)
//            return book
//        }
    }
    
    func getTotal() async -> Int {
        await self.getRootBooks().count
    }
    
    func delete(_ book: Book, verbose: Bool) async {
//        try? self.disk.deleteFile(book.url)
//        self.emit(.audioDeleted)
    }
    
    func download(_ book: Book, verbose: Bool) async throws {
//        try await self.disk.download(book.url, reason: "BookDB.download", verbose: verbose)
    }
    
    func find(_ url: URL) async -> Book? {
        nil
//        let book = await self.db.findBook(url)
//        book?.setDB(self)
//        
//        return book
    }
}
