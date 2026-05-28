import CisumUI
import Foundation
import SwiftUI

actor ThemeCisumPlugin: SuperPlugin {
    static let shared = ThemeCisumPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 118 }

    nonisolated var title: String { String(localized: "Cisum", table: "Theme-Cisum") }
    nonisolated var description: String { String(localized: "Cisum default theme", table: "Theme-Cisum") }
    let iconName = "circle.hexagonpath.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
