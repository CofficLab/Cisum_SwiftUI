import CisumUI
import PluginAudio
import PluginAudioScene
import SwiftUI

struct AudioControlPluginRootView<Content>: View where Content: View {
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
                guard let repo = AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getNextOf(current, verbose: verbose)
            },
            previousAsset: { current, verbose in
                guard let repo = AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getPrevOf(current, verbose: verbose)
            },
            firstAsset: {
                guard let repo = AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getFirst()
            },
            lastAsset: {
                guard let repo = AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getLast()
            }
        ) {
            content
        }
    }
}
