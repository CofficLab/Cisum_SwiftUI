import CisumUIComponents
import SwiftUI

public actor ThemeGraphiteBlackPlugin: SuperPlugin {
    public static let shared = ThemeGraphiteBlackPlugin()
    public static let metadata = PluginMetadata(
        displayName: GraphiteBlackTheme().displayName,
        description: GraphiteBlackTheme().description,
        iconName: GraphiteBlackTheme().iconName,
        order: 155
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 155, themeId: GraphiteBlackTheme().identifier),
        chromeTheme: GraphiteBlackTheme(),
        editorThemeId: GraphiteBlackTheme().identifier
    )]
    }
}
