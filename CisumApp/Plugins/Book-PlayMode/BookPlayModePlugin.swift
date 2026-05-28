import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookPlayModePlugin: SuperPlugin, SuperLog {
    static let shared = BookPlayModePlugin()
    static let emoji = "📖🔄"
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 7，在 BookPlugin 相关插件之后执行
    static var order: Int { 7 }

    nonisolated var title: String { String(localized: "Book Play Mode", table: "Book-PlayMode") }
    nonisolated var description: String { String(localized: "Book play mode management", table: "Book-PlayMode") }
    let iconName = "repeat"
    

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookPlayModeRootView { content() })
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
