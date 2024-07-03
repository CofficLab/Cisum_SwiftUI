import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: Find
    
    func findBookState(_ url: URL) -> BookState? {
        os_log("\(self.label)FindBookState for \(url.lastPathComponent)")
        do {
            return try context.fetch(BookState.descriptorOf(url)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
    
    // MARK: Update
    
    func updateCurrent(_ bookURL: URL, currentURL: URL?) {
        os_log("\(self.label)UpdateCurrent: \(bookURL.lastPathComponent) -> \(currentURL?.lastPathComponent ?? "")")
        if let book = self.findBookState(bookURL) {
            book.currentURL = currentURL
        } else {
            context.insert(BookState(url: bookURL, currentURL: currentURL))
        }
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
