import CisumUI
import AudioPlugin
import AudioScenePlugin
import SwiftUI

struct AudioProgressPluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioProgressRootView(
            currentSceneName: { currentSceneName },
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
