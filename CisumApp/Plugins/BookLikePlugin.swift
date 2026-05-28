import Foundation
import MagicKit
import OSLog
import PluginBookLike
import SwiftUI

actor BookLikePlugin: SuperPlugin, SuperLog {
    static let shared = BookLikePlugin()
    static let emoji = BookLikePluginInfo.emoji
    static let verbose = false
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 6，在 BookPlugin 相关插件之后执行
    static var order: Int { BookLikePluginInfo.order }

    nonisolated var title: String { BookLikePluginInfo.title }
    nonisolated var description: String { BookLikePluginInfo.description }
    let iconName = BookLikePluginInfo.iconName
    

    /// 提供喜欢管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookLikePluginRootView(content: content))
    }
}

private struct BookLikePluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookLikeRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { pluginProvider.currentSceneName }
        ) {
            content
        }
    }
}
