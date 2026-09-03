import CisumUIComponents
import KernelCore
import SwiftUI

public actor ThemeSunsetPlugin: SuperPlugin {
    public static let shared = ThemeSunsetPlugin()
    public static let metadata = PluginMetadata(
        displayName: SunsetTheme().displayName,
        description: SunsetTheme().description,
        iconName: SunsetTheme().iconName,
        order: 140
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 140, themeId: SunsetTheme().identifier),
        chromeTheme: SunsetTheme(),
        editorThemeId: SunsetTheme().identifier
    )]
    }
}
