import Foundation
import MagicCore
import OSLog
import SwiftUI

actor VersionPlugin: SuperPlugin, SuperLog {
    static let emoji = "📱"

    let label: String = "Version"
    let hasPoster: Bool = false
    let description: String = "版本信息"
    let iconName: String = .iconVersionInfo
    let isGroup: Bool = false

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(MagicSettingSection {
            MagicSettingRow(title: "版本", description: "APP 的版本", icon: .iconVersionInfo, content: {
                Text(MagicApp.getVersion())
                    .font(.footnote)
            })
        })
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
