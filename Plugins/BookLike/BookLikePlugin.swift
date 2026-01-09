import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookLikePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "📚❤️"
    static let verbose = false
    private static var enabled: Bool { true }

    let title = "书籍喜欢管理"
    let description = "负责书籍喜欢状态的独立管理和存储"
    let iconName = "heart"
    let isGroup = false

    /// 提供喜欢管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookLikeRootView { content() })
    }

}

// MARK: - PluginRegistrant

extension BookLikePlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            // 注册顺序设为 6，确保在其他书籍相关插件之后
            await PluginRegistry.shared.register(order: 6) { Self() }
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
