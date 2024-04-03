import Foundation
import SwiftData

@Model
class PlayItem {
    var url: URL
    var order: Int = 0
    
    init(url: URL, order: Int) {
        self.url = url
        self.order = order
    }
}
