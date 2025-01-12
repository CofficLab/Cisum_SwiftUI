import Foundation
import MagicKit
import OSLog
import SwiftUI

actor ResetPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let label = "Reset"
    let hasPoster = false
    let description: String = "恢复默认配置"
    let iconName: String = .iconReset
    
    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(ResetSetting())
    }
}
