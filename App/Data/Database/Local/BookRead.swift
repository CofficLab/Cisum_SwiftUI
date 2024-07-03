import Foundation
import OSLog
import SwiftData

// MARK: Find

extension DB {
    static func findBook(_ url: URL, context: ModelContext, verbose: Bool = false) -> Book? {
        if verbose {
            os_log("\(self.label)FindBook -> \(url.lastPathComponent)")
        }
        
        do {
            return try context.fetch(FetchDescriptor<Book>(predicate: #Predicate<Book> {
                $0.url == url
            })).first
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
