import Foundation
import SwiftData

@Model
class DeviceData {
    var uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
    }
}
