import CisumUI
import Foundation
import SwiftUI

actor ThemeMidnightPlugin: SuperPlugin {
    static let shared = ThemeMidnightPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 119 }

    nonisolated var title: String { String(localized: "Midnight Blue", table: "Theme-Midnight") }
    nonisolated var description: String { String(localized: "Night listening theme", table: "Theme-Midnight") }
    let iconName = "moon.stars.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MidnightTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
