import Foundation
import MagicCore
import OSLog
import SwiftUI

actor DebugPlugin: SuperPlugin, PluginRegistrant {
    let label = "Debug"
    let hasPoster = false
    let description: String = "调试专用"
    let iconName: String = .iconDebug
    nonisolated(unsafe) var enabled = true

    @MainActor
    func addSettingView() -> AnyView? {
        #if DEBUG
        guard enabled else { return nil }
        return AnyView(MagicSettingSection {
            MagicSettingRow(title: "调试", description: "调试相关", icon: .iconDebug) {
                Logger.logButton().magicSize(.small)
            }
        })
        #else
        return nil
        #endif
    }
}

// MARK: - PluginRegistrant
extension DebugPlugin {
    @objc static func register() {
        Task {
            await PluginRegistry.shared.register(id: "Debug", order: 100) {
                DebugPlugin()
            }
        }
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
