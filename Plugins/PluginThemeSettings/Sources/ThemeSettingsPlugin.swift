import CisumUI
import SwiftUI

public actor ThemeSettingsPlugin: SuperPlugin {
    public static let shared = ThemeSettingsPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { ThemeSettingsPluginInfo.order }

    public nonisolated var title: String { ThemeSettingsPluginInfo.title }
    public nonisolated var description: String { ThemeSettingsPluginInfo.description }
    public nonisolated var iconName: String { ThemeSettingsPluginInfo.iconName }

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
