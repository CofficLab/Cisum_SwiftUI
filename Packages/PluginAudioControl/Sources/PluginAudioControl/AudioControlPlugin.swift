import CisumUI
import PluginAudio
import PluginAudioScene
import SwiftUI

public actor AudioControlPlugin: SuperPlugin {
    public static let shared = AudioControlPlugin()
    public static var shouldRegister: Bool { true }

    public nonisolated var title: String { AudioControlPluginInfo.title }
    public nonisolated var description: String { AudioControlPluginInfo.description }
    public nonisolated var iconName: String { AudioControlPluginInfo.iconName }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioControlPluginRootView(content: content))
    }
}

private struct AudioControlPluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioControlRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            currentSceneName: { currentSceneName },
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
