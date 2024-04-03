import Foundation
import SwiftData

@Model
class PlayItem {
    var url: URL
    var order: Int = 0
    
    var title: String { url.lastPathComponent }
    
    init(_ url: URL, order: Int = 0) {
        self.url = url
        self.order = order
    }
}
