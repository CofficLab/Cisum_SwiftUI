import CisumUIComponents
import SwiftUI

public actor ThemeAuroraPlugin: SuperPlugin {
    public static let shared = ThemeAuroraPlugin()
    public static let metadata = PluginMetadata(
        displayName: AuroraTheme().displayName,
        description: AuroraTheme().description,
        iconName: AuroraTheme().iconName,
        order: 120
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 120, themeId: AuroraTheme().identifier),
        chromeTheme: AuroraTheme(),
        editorThemeId: AuroraTheme().identifier
    )]
    }
}
