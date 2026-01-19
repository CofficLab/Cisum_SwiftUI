import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookPlayModePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "📖🔄"
    static let verbose = true
    private static var enabled: Bool { true }

    let title = "书籍播放模式管理"
    let description = "负责书籍播放模式的设置和管理"
    let iconName = "repeat"
    let isGroup = false

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookPlayModeRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension BookPlayModePlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            // 注册顺序设为 7，确保在其他书籍相关插件之后
            await PluginRegistry.shared.register(order: 7) { Self() }
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
