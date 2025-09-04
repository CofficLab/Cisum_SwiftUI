import Foundation
import MagicCore

import OSLog
import SwiftUI

actor StoragePlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let dirName = "audios"
    let label = "Setting"
    let hasPoster = false
    let description = "存储设置"
    let iconName: String = .iconSettings
    let isGroup = false
    nonisolated(unsafe) var enabled = true

    @MainActor
    func addSettingView() -> AnyView? {
        guard enabled else { return nil }
        return AnyView(StorageSettingView())
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 800)
}

// MARK: - Preview

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
