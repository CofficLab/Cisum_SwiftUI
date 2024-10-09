import Foundation
import MagicKit
import OSLog

class BookUpdateCoverJob: SuperLog, SuperThread {
    let emoji = "🌽"
    let db: DB
    var running = false
    
    init(db: DB) {
        self.db = db
    }
    
    func run() {
        let verbose = false

        if running {
            return
        }

        running = true

        if verbose {
            os_log("\(self.t)run")
        }

        self.bg.async {
            Task {
                let books = await self.db.getBooksWithNoCoverData()

                if books.isEmpty {
                    self.running = false
                    if verbose {
                        os_log("\(self.t)run -> 没有任务")
                    }
                    return
                }

                for book in books {
                    self.updateBookCover(book: book)
                }

                self.running = false
            }
        }
    }

    func updateBookCover(book: Book) {
        if book.coverData != nil {
            return
        }

        Task {
            if let coverURL = await book.getCoverURLFromFile() {
                await db.updateBookCover(bookURL: book.url, coverURL: coverURL)
            }
        }
    }
}
