import CisumUIComponents
import SwiftUI

public actor ThemePaperPlugin: SuperPlugin {
    public static let shared = ThemePaperPlugin()
    public static let metadata = PluginMetadata(
        displayName: PaperTheme().displayName,
        description: PaperTheme().description,
        iconName: PaperTheme().iconName,
        order: 200
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 200, themeId: PaperTheme().identifier),
        chromeTheme: PaperTheme(),
        editorThemeId: PaperTheme().identifier
    )]
    }
}
