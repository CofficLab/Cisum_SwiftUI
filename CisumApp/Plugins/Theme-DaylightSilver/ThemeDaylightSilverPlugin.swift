import CisumUI
import Foundation
import SwiftUI

actor ThemeDaylightSilverPlugin: SuperPlugin {
    static let shared = ThemeDaylightSilverPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 126 }

    nonisolated var title: String { String(localized: "Daylight Silver", table: "Theme-DaylightSilver") }
    nonisolated var description: String { String(localized: "Daytime office theme", table: "Theme-DaylightSilver") }
    let iconName = "sun.max.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: DaylightSilverTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
