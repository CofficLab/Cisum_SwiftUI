import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookLikePlugin: SuperPlugin, SuperLog {
    static let shared = BookLikePlugin()
    static let emoji = "📚❤️"
    static let verbose = false
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 6，在 BookPlugin 相关插件之后执行
    static var order: Int { 6 }

    let title = "书籍喜欢管理"
    let description = "负责书籍喜欢状态的独立管理和存储"
    let iconName = "heart"
    

    /// 提供喜欢管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookLikeRootView { content() })
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
