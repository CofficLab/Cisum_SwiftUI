import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioDownloadPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "⬇️"
    static let verbose = true
    private static var enabled: Bool { true }

    let title = "音频下载管理"
    let description = "负责音频文件的自动下载"
    let iconName = "icloud.and.arrow.down"
    let isGroup = false

    /// 只有当当前插件是音频插件时才提供下载管理
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDownloadRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension AudioDownloadPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀 Register")
            }

            // 注册顺序设为 1，在 AudioPlugin (order: 0) 之后执行
            await PluginRegistry.shared.register(order: 1) { Self() }
        }
    }
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
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    ContentView()
    .inRootView()
}
#endif
