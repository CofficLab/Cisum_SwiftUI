import Foundation
import MagicCore
import OSLog
import SwiftUI

actor AudioProgressPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "💾"
    static let verbose = true

    let title = "音频进度管理"
    let description = "负责音频播放进度的保存和恢复"
    let iconName = "waveform"
    let isGroup = false

    /// 只有当当前插件是音频插件时才提供进度管理
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioProgressRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension AudioProgressPlugin {
    @objc static func register() {
        Task {
            if Self.verbose {
                os_log("\(self.t)🚀🚀🚀 Register")
            }

            // 注册顺序设为 0，确保在 AudioPlugin (order: 0) 之前执行
            // 内核会按顺序应用插件，进度管理先于音频功能
            await PluginRegistry.shared.register(order: 0) { Self() }
        }
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
