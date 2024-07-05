import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: Find
    
    func findBook(_ url: URL) -> Book? {
        os_log("\(self.label)FindBook for \(url.lastPathComponent)")
        do {
            return try context.fetch(Book.descriptorOf(url)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
}
