import Foundation
import MagicKit
import OSLog
import PluginAudioDownload
import SwiftUI

actor AudioDownloadPlugin: SuperPlugin, SuperLog {
    static let shared = AudioDownloadPlugin()
    static let emoji = AudioDownloadPluginInfo.emoji
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 2，在 AudioPlugin (order: 1) 之后执行
    static var order: Int { AudioDownloadPluginInfo.order }

    nonisolated var title: String { AudioDownloadPluginInfo.title }
    nonisolated var description: String { AudioDownloadPluginInfo.description }
    let iconName = AudioDownloadPluginInfo.iconName

    /// 只有当当前插件是音频插件时才提供下载管理
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDownloadPluginRootView { content() })
    }
}

private struct AudioDownloadPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioDownloadRootView(currentSceneName: { pluginProvider.currentSceneName }) {
            content
        }
    }
}
