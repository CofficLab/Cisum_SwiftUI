import CisumUI
import PluginAudio
import PluginAudioScene
import SwiftUI

public actor AudioPlayModePlugin: SuperPlugin {
    public static let shared = AudioPlayModePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { AudioPlayModePluginInfo.order }

    public nonisolated var title: String { AudioPlayModePluginInfo.title }
    public nonisolated var description: String { AudioPlayModePluginInfo.description }
    public nonisolated var iconName: String { AudioPlayModePluginInfo.iconName }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioPlayModePluginRootView(content: content))
    }
}

private struct AudioPlayModePluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioPlayModeRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            currentSceneName: { currentSceneName },
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
