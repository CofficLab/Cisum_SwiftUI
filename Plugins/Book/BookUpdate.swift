import Foundation
import OSLog

extension BookRecordDB {
    func updateBookParent(verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)UpdateBookParent start(\(self.getBookCount()))")
        }
        
        do {
            try context.enumerate(Book.descriptorOfNeedUpdateParent(), block: { book in
                book.parent = try context.fetch(Book.descriptorOf(book.parentBookURL!)).first
            })
            
            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }
        
        if verbose {
            os_log("\(self.t)UpdateBookParent done")
        }
        
        self.updateChildCount()
    }
    
    func updateChildCount(verbose: Bool = true) {
        do {
            try context.enumerate(Book.descriptorOfNeedUpdateParent(), block: { book in
                book.childCount = book.children?.count ?? 0
            })
            
            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }
        
        if verbose {
            os_log("\(self.t)UpdateChildCount done")
        }
    }
    
//    func updateOnInserted(_ urls: [URL], verbose: Bool = true) {
//        for url in urls {
//            if let book = self.findBook(url), book.parent == nil {
//                // 更新Parent
//                guard let parentURL = book.parentURL else {
//                    if verbose {
//                        os_log("\(self.t)UpdateBookParent for \(book.title) ignore because of no parentURL")
//                    }
//
//                    return
//                }
//
//                let parent = self.findBook(parentURL)
//                book.parent = parent
//
//                // 更新Children
//                do {
//                    try context.enumerate(Book.descriptorOfParentBookURL(url), block: { item in
//                        item.parent = book
//                    })
//                } catch {
//                    os_log(.error, "\(error.localizedDescription)")
//                }
//            }
//        }
//
//        do {
//            try context.save()
//            
//            if verbose {
//                os_log("\(self.t)UpdateOnInserted(\(urls.count) done")
//            }
//        } catch {
//            os_log(.error, "\(error.localizedDescription)")
//        }
//    }
//
//    func updateOnInserted(_ url: URL) {
//        guard let book = findBook(url) else {
//            return
//        }
//
//        if book.parent == nil {
//            updateParent(book)
//        }
//
//        do {
//            try context.enumerate(Book.descriptorOfParentBookURL(url), block: { item in
//                item.parent = book
//            })
//
//            try context.save()
//        } catch {
//            os_log(.error, "\(error.localizedDescription)")
//        }
//    }
//
    func updateParent(_ book: Book, verbose: Bool = true) {
        guard let parentURL = book.parentURL else {
            if verbose {
                os_log("\(self.t)UpdateBookParent for \(book.bookTitle) ignore because of no parentURL")
            }

            return
        }

        let parent = findBook(parentURL)
        book.parent = parent

        if verbose {
            os_log("\(self.t)UpdateBookParent for \(book.bookTitle) with \(parent?.title ?? "nil")")
        }

        do {
            try context.save()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }
    }

    func updateBookCover(bookURL: URL, coverData: Data) {
        let verbose = true
        guard let book = findBook(bookURL) else {
            if verbose {
                os_log("Failed to find book at URL: \(bookURL)")
            }
            return
        }
        
        do {
            book.coverData = coverData
            book.hasGetCover = true
            
            try context.save()
            
            if verbose {
                os_log("\(self.t)Successfully updated cover for book: \(book.bookTitle)")
            }
        } catch {
            os_log(.error, "\(self.t)Failed to update book cover: \(error.localizedDescription)")
        }
    }
    
    func updateBookSetNoCover(bookURL: URL) {
        let verbose = true
        guard let book = findBook(bookURL) else {
            if verbose {
                os_log("Failed to find book at URL: \(bookURL)")
            }
            return
        }
        
        do {
            book.hasGetCover = true
            
            try context.save()
        } catch {
            os_log(.error, "Failed to update book cover: \(error.localizedDescription)")
        }
    }
}
