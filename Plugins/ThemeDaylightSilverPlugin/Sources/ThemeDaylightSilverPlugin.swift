import CisumUI
import SwiftUI

public actor ThemeDaylightSilverPlugin: SuperPlugin {
    public static let shared = ThemeDaylightSilverPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeDaylightSilverPlugin",
        displayName: DaylightSilverTheme().displayName,
        description: DaylightSilverTheme().description,
        iconName: DaylightSilverTheme().iconName,
        order: 110
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: DaylightSilverTheme())]
    }
}
