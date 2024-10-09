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
        let verbose = true

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

                if verbose {
                    os_log("\(self.t)run -> 完成")
                }
            }
        }
    }

    func updateBookCover(book: Book) {
        let verbose = false
        let verbose2 = false

        if verbose {
            os_log("\(self.t)UpdateBookCover for \(book.bookTitle)")
        }

        if book.coverData != nil {
            if verbose2 {
                os_log("  ➡️ Already Have Cover, Ignore")
            }
            return
        }

        Task {
            if let coverURL = await book.getCoverURLFromFile() {
                if verbose2 {
                    os_log("  🎉 Got Cover URL")
                }
                await db.updateBookCover(bookURL: book.url, coverURL: coverURL)
            } else {
                if verbose2 {
                    os_log("  ☹️ No Cover URL")
                }
            }
        }
    }
}
