import CisumUIComponents
import KernelCore
import SwiftUI

public actor ThemeCisumPlugin: SuperPlugin {
    public static let shared = ThemeCisumPlugin()
    public static let metadata = PluginMetadata(
        displayName: CisumTheme().displayName,
        description: CisumTheme().description,
        iconName: CisumTheme().iconName,
        order: 100
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 100, themeId: CisumTheme().identifier),
        chromeTheme: CisumTheme(),
        editorThemeId: CisumTheme().identifier
    )]
    }
}
