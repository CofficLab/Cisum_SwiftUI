import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookControlPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🎮📚"
    static let verbose = true
    private static var enabled: Bool { true }

    let title = "书籍播放控制"
    let description = "负责书籍播放控制功能，如上一章、下一章"
    let iconName = "playpause"
    let isGroup = false

    /// 提供播放控制功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookControlRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension BookControlPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            // 注册顺序设为 8，确保在其他书籍相关插件之后
            await PluginRegistry.shared.register(order: 8) { Self() }
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
