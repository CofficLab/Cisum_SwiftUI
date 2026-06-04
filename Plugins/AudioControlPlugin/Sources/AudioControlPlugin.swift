import CisumUI
import AudioPlugin
import AudioScenePlugin
import SwiftUI

public actor AudioControlPlugin: SuperPlugin {
    public static let shared = AudioControlPlugin()
    public static let metadata = PluginMetadata(
        id: "AudioControlPlugin",
        displayName: AudioControlPluginInfo.title,
        description: AudioControlPluginInfo.description,
        iconName: AudioControlPluginInfo.iconName
    )

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioControlPluginRootView(content: content))
    }
}
