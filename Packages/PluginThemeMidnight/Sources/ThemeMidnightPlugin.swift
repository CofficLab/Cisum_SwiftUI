import CisumUIComponents
import SwiftUI

public actor ThemeMidnightPlugin: SuperPlugin {
    public static let shared = ThemeMidnightPlugin()
    public static let metadata = PluginMetadata(
        displayName: MidnightTheme().displayName,
        description: MidnightTheme().description,
        iconName: MidnightTheme().iconName,
        order: 160
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 160, themeId: MidnightTheme().identifier),
        chromeTheme: MidnightTheme(),
        editorThemeId: MidnightTheme().identifier
    )]
    }
}
