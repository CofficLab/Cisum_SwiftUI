import CisumUIComponents
import SwiftUI

public actor ThemeMonoPlugin: SuperPlugin {
    public static let shared = ThemeMonoPlugin()
    public static let metadata = PluginMetadata(
        displayName: MonoTheme().displayName,
        description: MonoTheme().description,
        iconName: MonoTheme().iconName,
        order: 170
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 170, themeId: MonoTheme().identifier),
        chromeTheme: MonoTheme(),
        editorThemeId: MonoTheme().identifier
    )]
    }
}
