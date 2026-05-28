import MagicKit
import PluginThemeSettings
import SwiftUI

actor ThemeSettingsPlugin: SuperPlugin {
    static let shared = ThemeSettingsPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { ThemeSettingsPluginInfo.order }

    nonisolated var title: String { ThemeSettingsPluginInfo.title }
    nonisolated var description: String { ThemeSettingsPluginInfo.description }
    let iconName = ThemeSettingsPluginInfo.iconName

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(ThemeSettingView())
    }
}

struct ThemeSettingView: View {
    @EnvironmentObject private var themeProvider: AppThemeProvider

    var body: some View {
        ThemeSettingsRootView(
            themes: themeProvider.themes,
            currentThemeId: themeProvider.currentThemeId,
            selectTheme: { themeId in
                themeProvider.selectTheme(themeId)
            }
        )
    }
}
