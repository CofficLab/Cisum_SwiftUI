import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderScene
import SwiftUI

struct AudioControlPluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?
    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        AudioControlRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            scene: scene,
            nextAsset: { current, verbose in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getNextOf(current, verbose: verbose)
            },
            previousAsset: { current, verbose in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getPrevOf(current, verbose: verbose)
            },
            firstAsset: {
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getFirst()
            },
            lastAsset: {
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getLast()
            }
        ) {
            content
        }
    }
}
