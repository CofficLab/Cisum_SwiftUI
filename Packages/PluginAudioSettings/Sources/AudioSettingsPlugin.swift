import CisumUI
import AudioPlugin
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
    public func addSettingView() -> AnyView? {
        AnyView(AudioSettingsPluginView())
    }
}
