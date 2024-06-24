import Foundation
import SwiftData

@Model
class CopyTask {
    var url: URL
    var createdAt: Date
    var error: String = ""
    var isRunning: Bool = false
    
    var title: String { url.lastPathComponent }
    var time: String { TimeHelper.getTimeString2() }
    var message: String {
        if isRunning {
            return "进行中"
        }
    
        return error
    }
    
    init(url: URL) {
        self.url = url
        self.createdAt = .now
    }
}

// MARK: ID

extension CopyTask: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}
