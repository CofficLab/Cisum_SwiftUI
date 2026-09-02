import CisumUIComponents
import SwiftUI

public actor ThemeStudioBluePlugin: SuperPlugin {
    public static let shared = ThemeStudioBluePlugin()
    public static let metadata = PluginMetadata(
        displayName: StudioBlueTheme().displayName,
        description: StudioBlueTheme().description,
        iconName: StudioBlueTheme().iconName,
        order: 130
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 130, themeId: StudioBlueTheme().identifier),
        chromeTheme: StudioBlueTheme(),
        editorThemeId: StudioBlueTheme().identifier
    )]
    }
}
