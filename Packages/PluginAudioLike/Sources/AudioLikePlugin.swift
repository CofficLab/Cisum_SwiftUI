import CisumUI
import AudioScenePlugin
import SwiftUI

public actor AudioLikePlugin: SuperPlugin {
    public static let shared = AudioLikePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioLikePluginInfo.title,
        description: AudioLikePluginInfo.description,
        iconName: AudioLikePluginInfo.iconName,
        order: AudioLikePluginInfo.order
    )

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioLikePluginRootView(content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "liked-audio",
            title: String(localized: "Liked audio", bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(AudioLikeSettingsView())
        )
    }
}
