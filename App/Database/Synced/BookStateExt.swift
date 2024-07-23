import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: FindOrInsert
    
    nonisolated func findOrInsertBookState(_ url: URL, verbose: Bool = false) -> BookState? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)FindOrInsertBookState for \(url.lastPathComponent)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        if let state = self.findBookState(url) {
            return state
        } else {
            context.insert(BookState(url: url, currentURL: nil))
            
            do {
                try context.save()
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
                
                return nil
            }
            
            return self.findBookState(url)
        }
    }
    
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
        os_log("\(self.t)UpdateCurrent: \(bookURL.lastPathComponent) -> \(currentURL?.lastPathComponent ?? "")")
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
