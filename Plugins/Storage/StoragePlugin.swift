import Foundation
import MagicKit

import OSLog
import SwiftUI

actor StoragePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "⚙️"
    private static var enabled: Bool { false }
    private static let verbose = true

    let dirName = "audios"
    let label = "Setting"
    let description = "存储设置"
    let iconName: String = .iconSettings
    let isGroup = false

    @MainActor
    func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)⚙️ 加载存储设置视图")
        }

        return AnyView(StorageSettingView())
    }
}

// MARK: - PluginRegistrant
extension StoragePlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        if Self.verbose {
            os_log("\(self.t)🚀 Register")
        }

        Task {
            await PluginRegistry.shared.register(id: "Storage", order: 10) {
                StoragePlugin()
            }
        }
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
    ContentView()
    .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
    .inRootView()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    ContentView()
    .inRootView()
}
#endif
