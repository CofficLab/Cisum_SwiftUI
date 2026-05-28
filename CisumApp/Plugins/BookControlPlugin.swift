import Foundation
import MagicKit
import OSLog
import PluginBookControl
import SwiftUI

actor BookControlPlugin: SuperPlugin, SuperLog {
    static let shared = BookControlPlugin()
    static let emoji = BookControlPluginInfo.emoji
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 8，在其他书籍相关插件之后执行
    static var order: Int { BookControlPluginInfo.order }

    nonisolated var title: String { BookControlPluginInfo.title }
    nonisolated var description: String { BookControlPluginInfo.description }
    nonisolated var iconName: String { BookControlPluginInfo.iconName }
    

    /// 提供播放控制功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookControlPluginRootView(content: content))
    }
}

private struct BookControlPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookControlRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { pluginProvider.currentSceneName }
        ) {
            content
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
