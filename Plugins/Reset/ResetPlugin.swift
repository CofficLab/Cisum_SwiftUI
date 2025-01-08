import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

actor ResetPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let label = "Reset"
    let hasPoster = true
    let description: String = "恢复默认配置"
    let iconName = "music.note"

    init() {
        os_log("\(self.i)")
    }
    
    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(ResetSetting())
    }
}
