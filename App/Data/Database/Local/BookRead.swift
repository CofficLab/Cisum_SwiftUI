import Foundation
import OSLog
import SwiftData

extension DB {
    func getBookCount() -> Int {
        do {
            return try context.fetchCount(Book.descriptorAll)
        } catch {
            os_log(.error, "\(error.localizedDescription)")
            
            return 0
        }
    }
}

// MARK: Find

extension DB {
    static func findBook(_ url: URL, context: ModelContext, verbose: Bool = false) -> Book? {
        if verbose {
            os_log("\(self.label)FindBook -> \(url.lastPathComponent)")
        }
        
        do {
            return try context.fetch(Book.descriptorOf(url)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
    
    func findBook(_ url: URL) -> Book? {
        Self.findBook(url, context: context)
    }
    
    func findBook(_ id: Book.ID) -> Book? {
        context.model(for: id) as? Book
    }
    
    func findOrCreateBook(_ url: URL) -> Book? {
        if let book = self.findBook(url) {
            return book
        } else {
            let book = Book(url: url)
            context.insert(Book(url: url))
            
//            do {
//                try context.save()
//            } catch {
//                os_log(.error, "\(error.localizedDescription)")
//            }
            return book
//            return self.findBook(url)
        }
    }
}

// MARK: Children

extension DB {
    func getChildren(_ url: URL, verbose: Bool = true) -> [Book] {
        if verbose {
            os_log("\(self.label)GetChildren -> \(url.lastPathComponent)")
        }
        
        do {
            return try context.fetch(FetchDescriptor<Book>(predicate: #Predicate<Book> {
                $0.url.absoluteString == url.absoluteString
            }))
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return []
    }
}
