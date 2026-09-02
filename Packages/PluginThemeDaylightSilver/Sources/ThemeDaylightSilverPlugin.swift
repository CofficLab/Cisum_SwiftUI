import CisumUIComponents
import SwiftUI

public actor ThemeDaylightSilverPlugin: SuperPlugin {
    public static let shared = ThemeDaylightSilverPlugin()
    public static let metadata = PluginMetadata(
        displayName: DaylightSilverTheme().displayName,
        description: DaylightSilverTheme().description,
        iconName: DaylightSilverTheme().iconName,
        order: 110
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 110, themeId: DaylightSilverTheme().identifier),
        chromeTheme: DaylightSilverTheme(),
        editorThemeId: DaylightSilverTheme().identifier
    )]
    }
}
