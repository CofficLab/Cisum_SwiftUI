import CisumUI
import SwiftUI

public actor ThemeSettingsPlugin: SuperPlugin {
    public static let shared = ThemeSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: ThemeSettingsPluginInfo.title,
        description: ThemeSettingsPluginInfo.description,
        iconName: ThemeSettingsPluginInfo.iconName,
        order: ThemeSettingsPluginInfo.order
    )

    @MainActor
    public func addSettingView() -> AnyView? {
        AnyView(ThemeSettingView())
    }
}
