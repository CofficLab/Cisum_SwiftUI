import Foundation
import SwiftData

@Model
class Cover {
    @Attribute(.unique)
    var audio: URL

    // nil表示未计算过，true表示有，false表示没有
    var hasCover: Bool?
    var title: String
    var createdAt: Date = Date.now

    init(audio: Audio, hasCover: Bool) {
        self.audio = audio.url
        self.hasCover = hasCover
        self.title = audio.url.lastPathComponent
    }
}
