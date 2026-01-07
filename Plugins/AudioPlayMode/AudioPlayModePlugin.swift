import Foundation
import MagicCore
import OSLog
import SwiftUI

actor AudioPlayModePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🔄"
    static let verbose = true

    let title = "音频播放模式管理"
    let description = "负责音频播放模式的设置和管理"
    let iconName = "repeat"
    let isGroup = false

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioPlayModeRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension AudioPlayModePlugin {
    @objc static func register() {
        Task {
            // 注册顺序设为 3，确保在 AudioProgressPlugin (order: 0) 和 AudioPlugin (order: 1) 之后
            await PluginRegistry.shared.register(order: 3) { Self() }
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
