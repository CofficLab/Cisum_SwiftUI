import CisumUIComponents
import SwiftUI

public actor ThemeForestPlugin: SuperPlugin {
    public static let shared = ThemeForestPlugin()
    public static let metadata = PluginMetadata(
        displayName: ForestTheme().displayName,
        description: ForestTheme().description,
        iconName: ForestTheme().iconName,
        order: 150
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 150, themeId: ForestTheme().identifier),
        chromeTheme: ForestTheme(),
        editorThemeId: ForestTheme().identifier
    )]
    }
}
