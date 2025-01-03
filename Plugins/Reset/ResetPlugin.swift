import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

class ResetPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let label: String = "Reset"
    var hasPoster: Bool = true
    let description: String = "恢复默认配置"
    var iconName: String = "music.note"

    init() {
        os_log("\(self.i)")
    }
    
    func addSettingView() -> AnyView? {
        AnyView(ResetSetting())
    }
}
