import Foundation
import MagicKit
import OSLog
import SwiftData

class BookUpdateCoverJob: SuperLog, SuperThread {
    let emoji = "🌽"
    let db: DB
    var running = false

    init(container: ModelContainer) {
        self.db = DB(container, reason: "BookUpdateCoverJob.Init")
    }

    func run() {
        let verbose = true
        let verbose2 = false

        if running {
            return
        }

        running = true

        self.bg.async {
            Task {
                let books = await self.db.getBooksShouldUpdateCover()

                if books.isEmpty {
                    self.running = false
                    if verbose {
                        os_log("\(self.t)run -> 没有任务")
                    }
                    return
                }

                if verbose {
                    os_log("\(self.t)run(\(books.count))")
                }

                var count = 1
                for book in books {
                    if verbose2 {
                        os_log("\(self.t)run(\(books.count)) -> \(count)/\(books.count)")
                    }
                    
                    await self.updateBookCover(book: book)
                    count += 1
                }

                self.running = false

                if verbose {
                    os_log("\(self.t)run -> 完成 🎉🎉🎉")
                }
            }
        }
    }

    private func updateBookCover(book: Book) async {
        let verbose = false

        if verbose {
            os_log("\(self.t)UpdateBookCover for \(book.bookTitle)")
        }

        if book.coverData != nil {
            return
        }
        
        if book.isNotDownloaded {
            return
        }

        if let coverURL = await book.getCoverURLFromFile() {
            await db.updateBookCover(bookURL: book.url, coverURL: coverURL)
        } else {
            await db.updateBookSetNoCover(bookURL: book.url)
        }
    }
}
