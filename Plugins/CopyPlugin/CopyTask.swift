import Foundation
import SwiftData
import MagicKit
import MagicUI

@Model
class CopyTask {
    static var emoji: String = "🍁"
    
    var url: URL
    var destination: URL
    var createdAt: Date
    var error: String = ""
    var isRunning: Bool = false
    
    var title: String { url.lastPathComponent }
    var time: String { Date.now }
    var message: String {
        if isRunning {
            return "进行中"
        }
        
        if self.url.isDownloading {
            return "正在从 iCloud 下载"
        }
    
        return error
    }
    
    init(url: URL, destination: URL) {
        self.url = url
        self.destination = destination
        self.createdAt = .now
    }
}

// MARK: ID

extension CopyTask: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}
