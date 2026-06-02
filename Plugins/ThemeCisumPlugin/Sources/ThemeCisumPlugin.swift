import CisumUI
import SwiftUI

public actor ThemeCisumPlugin: SuperPlugin {
    public static let shared = ThemeCisumPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeCisumPlugin",
        displayName: CisumTheme().displayName,
        description: CisumTheme().description,
        iconName: CisumTheme().iconName,
        order: 100
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumTheme())]
    }
}
