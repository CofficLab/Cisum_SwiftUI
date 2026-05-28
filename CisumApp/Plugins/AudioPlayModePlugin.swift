import Foundation
import MagicKit
import OSLog
import PluginAudioPlayMode
import SwiftUI
import PluginAudio

actor AudioPlayModePlugin: SuperPlugin {
    static let shared = AudioPlayModePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { AudioPlayModePluginInfo.order }

    nonisolated var title: String { AudioPlayModePluginInfo.title }
    nonisolated var description: String { AudioPlayModePluginInfo.description }
    let iconName = AudioPlayModePluginInfo.iconName

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioPlayModePluginRootView(content: content))
    }
}

private struct AudioPlayModePluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioPlayModeRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            currentSceneName: { pluginProvider.currentSceneName },
            sort: { currentURL in
                await AudioPlugin.getAudioRepo()?.sort(currentURL, reason: "PlayModeChanged")
            },
            shuffle: { currentURL in
                try await AudioPlugin.getAudioRepo()?.sortRandom(currentURL, reason: "PlayModeChanged", verbose: false)
            }
        ) {
            content
        }
    }
}
