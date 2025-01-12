import Foundation
import MagicKit

import OSLog
import SwiftUI

actor SettingPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let dirName = "audios"
    let label = "Setting"
    let hasPoster = false
    let description = "设置"
    let iconName: String = .iconSettings
    let isGroup = false

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(SettingPluginView())
    }
}
