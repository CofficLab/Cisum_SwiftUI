import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: Find
    
    nonisolated func findBookState(_ url: URL, verbose: Bool = false) -> BookState? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)FindBookState for \(url.lastPathComponent)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        do {
            return try context.fetch(BookState.descriptorOf(url)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
    
    // MARK: Update
    
    func updateBookCurrent(_ bookURL: URL, currentURL: URL?) {
        os_log("\(self.label)UpdateCurrent: \(bookURL.lastPathComponent) -> \(currentURL?.lastPathComponent ?? "")")
        if let book = self.findBookState(bookURL) {
            book.currentURL = currentURL
            book.updateAt = .now
        } else {
            context.insert(BookState(url: bookURL, currentURL: currentURL))
        }
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
//    func updateCurrent(currentURL: URL) {
//        if let parent = self.findBook(currentURL.deletingLastPathComponent()) {
//            self.updateCurrent(parent.url, currentURL: currentURL)
//        }
//    }
}
