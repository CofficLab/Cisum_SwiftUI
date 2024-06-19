import Foundation
import OSLog
import SwiftData

extension DB {
    func findAudioGroup(_ hash: String, verbose: Bool = true) -> AudioGroup? {
        if verbose {
            os_log("\(self.label)FindAudioGroup -> \(hash)")
        }
        
        do {
            return try context.fetch(FetchDescriptor<AudioGroup>(predicate: #Predicate<AudioGroup> {
                $0.fileHash == hash
            })).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
}
