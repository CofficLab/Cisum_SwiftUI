import CisumUIComponents
import SwiftUI

struct ThemeSettingView: View {
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
