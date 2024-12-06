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
        let verbose = false
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

                self.updateCoverForFolder()

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

        if let data = await book.getCoverData() {
            await db.updateBookCover(bookURL: book.url, coverData: data)
        } else {
            await db.updateBookSetNoCover(bookURL: book.url)
        }
    }

    private func updateCoverForFolder() {
        self.bg.async {
            Task {
                let books = await self.db.getBooksOfCollectionType()

                if books.isEmpty {
                    return
                }

                for book in books {
                    if book.coverData != nil {
                        return
                    }
                    
                    if let data = await self.getCoverFromChildren(book: book) {
                        await self.db.updateBookCover(bookURL: book.url, coverData: data)
                    } else {
                        await self.db.updateBookSetNoCover(bookURL: book.url)
                    }
                }
            }
        }
    }

    private func getCoverFromChildren(book: Book) async -> Data? {
        if let data = book.coverData {
            return data
        }

        guard let children = book.childBooks else {
            return nil
        }

        for child in children {
            if let coverData = await getCoverFromChildren(book: child) {
                return coverData
            }
        }

        return nil
    }
}
