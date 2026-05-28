import CisumUI
import Foundation
import SwiftUI

actor ThemeSunsetPlugin: SuperPlugin {
    static let shared = ThemeSunsetPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 124 }

    nonisolated var title: String { String(localized: "Sunset Orange", table: "Theme-Sunset") }
    nonisolated var description: String { String(localized: "Warm accent theme", table: "Theme-Sunset") }
    let iconName = "sunset.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: SunsetTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
