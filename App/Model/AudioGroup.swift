import Foundation
import SwiftData

@Model
class AudioGroup {
    var title: String = ""
    
    @Attribute(.unique)
    var fileHash: String = ""
    
    var audios: [Audio] = []
    
    init(title: String, hash: String) {
        self.title = title
        self.fileHash = hash
    }
}
