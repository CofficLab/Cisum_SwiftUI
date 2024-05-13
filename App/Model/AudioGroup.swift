import Foundation
import SwiftData

@Model
class AudioGroup {
    var title: String = ""
    var createdAt: Date?
    var updatedAt: Date?
    
    @Attribute(.unique)
    var fileHash: String = ""
    
    var audios: [Audio] = []
    
    init(title: String, hash: String) {
        self.title = title
        self.fileHash = hash
        self.createdAt = .now
        self.updatedAt = .now
    }
}
