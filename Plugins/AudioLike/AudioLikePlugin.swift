import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

actor AudioLikePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "❤️"
    static let verbose = false

    let title = "音频喜欢管理"
    let description = "负责音频喜欢状态的独立管理和存储"
    let iconName = "heart"
    let isGroup = false

    /// 提供喜欢管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioLikeRootView { content() })
    }

    /// 提供喜欢状态的设置视图
    @MainActor func addSettingView() -> AnyView? {
        AnyView(AudioLikeSettingsView())
    }
}

// MARK: - PluginRegistrant

extension AudioLikePlugin {
    @objc static func register() {
        Task {
            // 注册顺序设为 2，确保在 AudioProgressPlugin (order: 0) 和 AudioPlugin (order: 1) 之后
            await PluginRegistry.shared.register(order: 2) { Self() }
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
