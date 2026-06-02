import CisumUI
import AudioPlugin
import AudioScenePlugin
import SwiftUI

public actor AudioPlayModePlugin: SuperPlugin {
    public static let shared = AudioPlayModePlugin()
    public static let metadata = PluginMetadata(
        id: "AudioPlayModePlugin",
        displayName: AudioPlayModePluginInfo.title,
        description: AudioPlayModePluginInfo.description,
        iconName: AudioPlayModePluginInfo.iconName,
        order: AudioPlayModePluginInfo.order
    )

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
                guard let repo = AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }
                await repo.sort(currentURL, reason: "PlayModeChanged")
            },
            shuffle: { currentURL in
                guard let repo = AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }
                try await repo.sortRandom(currentURL, reason: "PlayModeChanged", verbose: false)
            }
        ) {
            content
        }
    }
}
