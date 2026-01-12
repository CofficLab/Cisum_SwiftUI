import Foundation
import MagicKit
import OSLog
import SwiftUI

actor ResetPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "⚙️"
    private static var enabled: Bool { true }

    let label = "Reset"
    let description: String = "恢复默认配置"
    let iconName: String = .iconReset
    
    @MainActor
    func addSettingView() -> AnyView? {
        guard Self.enabled else { return nil }
        return AnyView(ResetSetting())
    }
}

// MARK: - PluginRegistrant
extension ResetPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            await PluginRegistry.shared.register(id: "Reset", order: 95) {
                ResetPlugin()
            }
        }
    }
}

#Preview("ResetConfirmContent") {
    RootView {
        ResetConfirmContent(onCancel: {}, onConfirm: {})
            .padding()
            .frame(width: 400)
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

