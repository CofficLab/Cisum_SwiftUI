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
