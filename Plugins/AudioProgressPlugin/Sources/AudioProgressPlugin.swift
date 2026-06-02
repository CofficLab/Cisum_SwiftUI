import CisumUI
import MagicKit
import AudioPlugin
import AudioScenePlugin
import SwiftUI

public actor AudioProgressPlugin: SuperPlugin, SuperLog {
    public static let shared = AudioProgressPlugin()
    public nonisolated static let emoji = "💾"
    public static let verbose = true
    public static let metadata = PluginMetadata(
        id: "AudioProgressPlugin",
        displayName: String(localized: String.LocalizationValue(AudioProgressPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(AudioProgressPluginInfo.descriptionKey), bundle: .module),
        iconName: "waveform",
        order: 0
    )

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioProgressPluginRootView(content: content))
    }
}

private struct AudioProgressPluginRootView<Content>: View where Content: View {
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
