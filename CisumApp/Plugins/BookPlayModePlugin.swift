import Foundation
import MagicKit
import OSLog
import PluginBookPlayMode
import SwiftUI

actor BookPlayModePlugin: SuperPlugin, SuperLog {
    static let shared = BookPlayModePlugin()
    static let emoji = BookPlayModePluginInfo.emoji
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 7，在 BookPlugin 相关插件之后执行
    static var order: Int { BookPlayModePluginInfo.order }

    nonisolated var title: String { BookPlayModePluginInfo.title }
    nonisolated var description: String { BookPlayModePluginInfo.description }
    nonisolated var iconName: String { BookPlayModePluginInfo.iconName }
    

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookPlayModePluginRootView(content: content))
    }
}

private struct BookPlayModePluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookPlayModeRootView(
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
