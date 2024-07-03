import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: Find
    
    func find(_ url: URL) -> BookState? {
        do {
            return try context.fetch(BookState.descriptorOf(url)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
}
