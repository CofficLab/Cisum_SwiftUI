import CisumUIComponents
import SwiftUI

public actor ThemeNebulaPlugin: SuperPlugin {
    public static let shared = ThemeNebulaPlugin()
    public static let metadata = PluginMetadata(
        displayName: NebulaTheme().displayName,
        description: NebulaTheme().description,
        iconName: NebulaTheme().iconName,
        order: 180
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 180, themeId: NebulaTheme().identifier),
        chromeTheme: NebulaTheme(),
        editorThemeId: NebulaTheme().identifier
    )]
    }
}
