import Foundation
import SwiftData

@Model
class CopyTask {
    var url: URL
    var createdAt: Date
    var error: String = ""
    var succeed: Bool = false
    var finished: Bool = false
    var isRunning: Bool = false
    
    var title: String { url.lastPathComponent }
    var message: String {
        if finished == false {
            return "进行中"
        }
        
        if succeed == false {
            return error
        }
        
        return "成功"
    }
    
    init(url: URL) {
        self.url = url
        self.createdAt = .now
    }
}
