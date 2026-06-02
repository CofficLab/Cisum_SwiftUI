import CisumUI
import SwiftUI

public actor ThemeSettingsPlugin: SuperPlugin {
    public static let shared = ThemeSettingsPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeSettingsPlugin",
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

private struct ThemeSettingView: View {
    @Environment(\.pluginThemes) private var themes
    @Environment(\.currentPluginThemeId) private var currentThemeId
    @Environment(\.selectPluginThemeAction) private var selectTheme

    var body: some View {
        ThemeSettingsRootView(
            themes: themes,
            currentThemeId: currentThemeId,
            selectTheme: { themeId in
                selectTheme(themeId)
            }
        )
    }
}
