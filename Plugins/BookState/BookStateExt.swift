import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: FindOrInsert
    
    nonisolated func findOrInsertBookState(_ url: URL, verbose: Bool = false) -> BookState? {
        if verbose {
            os_log("\(self.t)FindOrInsertBookState for \(url.lastPathComponent)")
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
            os_log("\(self.t)FindBookState for \(url.lastPathComponent)")
        }
        
        let context = ModelContext(self.modelContainer)
        
        do {
            let descriptor = BookState.descriptorOf(url)
            let result = try context.fetch(descriptor)
            return result.first
        } catch let fetchError as NSError {
            os_log(.error, "Fetch error: \(fetchError.localizedDescription)")
            if let underlyingError = fetchError.userInfo[NSUnderlyingErrorKey] as? NSError {
                os_log(.error, "Underlying error: \(underlyingError.localizedDescription)")
            }
            return nil
        } catch {
            os_log(.error, "Unknown error: \(error.localizedDescription)")
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
