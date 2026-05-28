import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookControlPlugin: SuperPlugin, SuperLog {
    static let shared = BookControlPlugin()
    static let emoji = "🎮📚"
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 8，在其他书籍相关插件之后执行
    static var order: Int { 8 }

    nonisolated var title: String { String(localized: "Book Playback Control", table: "Book-Control") }
    nonisolated var description: String { String(localized: "Book playback control, such as previous and next chapter", table: "Book-Control") }
    let iconName = "playpause"
    

    /// 提供播放控制功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookControlRootView { content() })
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
