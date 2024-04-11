import Foundation
import SwiftData

@Model
class CopyTask {
    var url: URL
    var createdAt: Date
    
    init(url: URL) {
        self.url = url
        self.createdAt = .now
    }
}
