import Foundation
import SwiftData

@Model
class DeviceData {
    var uuid: String = ""
    var firstOpenTime: Date = Date.distantPast
    var lastOpenTime: Date = Date.distantPast
    var timesOpened: Int = 0
    var audioCount: Int = 0
    var name: String = ""
    var model: String = ""
    var os: String = ""
    var version: String = ""
    
    init(uuid: String) {
        self.uuid = uuid
    }
}
