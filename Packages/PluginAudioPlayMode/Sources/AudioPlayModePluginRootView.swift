import CisumUIComponents
import PluginAudio
import PluginAudioScene
import SwiftUI

struct AudioPlayModePluginRootView<Content>: View where Content: View {
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
