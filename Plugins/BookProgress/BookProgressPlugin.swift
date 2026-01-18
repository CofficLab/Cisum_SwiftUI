import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookProgressPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "📖"
    static let verbose = true
    private static var enabled: Bool { false }

    let title = "书籍进度管理"
    let description = "负责书籍播放进度的保存和恢复"
    let iconName = "book.closed"
    let isGroup = false

    /// 提供进度管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookProgressRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension BookProgressPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀🚀🚀 Register")
            }
            // 注册顺序设为 5，确保在 BookPlugin (order: 1) 之后
            await PluginRegistry.shared.register(order: 5) { Self() }
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
