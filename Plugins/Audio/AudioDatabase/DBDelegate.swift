import Foundation
import OSLog

protocol AudioDBDelegate {
    func onDelete(_ uuid: String)
}

extension AudioDBDelegate {
    func onDelete(_ uuid: String) {
        os_log("onDelete \(uuid)")
    }
}
