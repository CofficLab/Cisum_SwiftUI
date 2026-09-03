import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderScene
import SwiftUI

struct AudioProgressPluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?

    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        AudioProgressRootView(
            scene: scene,
            audioSceneName: AudioScenePlugin.sceneName,
            audioRepo: { AudioPlugin.getAudioRepo() },
            storageResetNotifications: [Notification.Name("storageLocationDidReset")],
            saveWidgetData: { title, artist, isPlaying, coverArt in
                AudioProgressHost.saveWidgetData(title: title, artist: artist, isPlaying: isPlaying, coverArt: coverArt)
            },
            content: { content }
        )
    }
}
