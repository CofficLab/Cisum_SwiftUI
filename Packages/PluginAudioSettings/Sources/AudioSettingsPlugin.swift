import CisumUIComponents
import KernelCore
import PluginAudio
import SwiftUI

public actor AudioSettingsPlugin: SuperPlugin {
    public static let shared = AudioSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioSettingsPluginInfo.title,
        description: AudioSettingsPluginInfo.description,
        iconName: AudioSettingsPluginInfo.iconName,
        order: AudioSettingsPluginInfo.order
    )

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "audio-settings",
            title: AudioSettingsPluginInfo.title,
            description: Self.metadata.description,
            iconName: "slider.horizontal.3",
            order: AudioSettingsPluginInfo.order,
            destination: AnyView(AudioSettingsPluginView())
        )
    }
}
