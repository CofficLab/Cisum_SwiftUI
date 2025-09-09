import Foundation
import MagicCore
import OSLog
import SwiftUI

actor StorePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🛒"

    let label: String = "Store"
    let hasPoster: Bool = false
    let description: String = "应用内购买和订阅"
    let iconName: String = "cart"
    let isGroup: Bool = false

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(StoreSettingEntry())
    }
}

// MARK: - PluginRegistrant
extension StorePlugin {
    @objc static func register() {
        Task {
            await PluginRegistry.shared.register(id: "Store", order: 80) {
                StorePlugin()
            }
        }
    }
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
