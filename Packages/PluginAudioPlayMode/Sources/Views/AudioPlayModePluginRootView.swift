import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderScene
import SwiftUI

struct AudioPlayModePluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?
    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        AudioPlayModeRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            scene: scene,
            sort: { currentURL in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                await repo.sort(currentURL, reason: "PlayModeChanged")
            },
            shuffle: { currentURL in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                try await repo.sortRandom(currentURL, reason: "PlayModeChanged", verbose: false)
            }
        ) {
            content
        }
    }
}
