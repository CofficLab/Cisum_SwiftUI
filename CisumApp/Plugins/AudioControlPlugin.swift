import Foundation
import PluginAudioControl
import SwiftUI
import PluginAudio

actor AudioControlPlugin: SuperPlugin {
    static let shared = AudioControlPlugin()
    static let emoji = "🎮"
    static let verbose = true
    static var shouldRegister: Bool { true }

    nonisolated var title: String { AudioControlPluginInfo.title }
    nonisolated var description: String { AudioControlPluginInfo.description }
    nonisolated var iconName: String { AudioControlPluginInfo.iconName }

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioControlPluginRootView(content: content))
    }
}

private struct AudioControlPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioControlRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            currentSceneName: { pluginProvider.currentSceneName },
            nextAsset: { current, verbose in
                try await AudioPlugin.getAudioRepo()?.getNextOf(current, verbose: verbose)
            },
            previousAsset: { current, verbose in
                try await AudioPlugin.getAudioRepo()?.getPrevOf(current, verbose: verbose)
            },
            firstAsset: {
                try await AudioPlugin.getAudioRepo()?.getFirst()
            }
        ) {
            content
        }
    }
}
