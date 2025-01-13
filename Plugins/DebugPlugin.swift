import Foundation
import MagicKit
import OSLog
import SwiftUI

actor DebugPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let label = "Debug"
    let hasPoster = false
    let description: String = "调试专用"
    let iconName: String = .iconDebug

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(MagicSettingSection {
            MagicSettingRow(title: "调试", description: "调试相关", icon: .iconDebug) {
                Logger.logButton().magicSize(.small)
            }
        })
    }
}
