import CisumUI
import Foundation
import SwiftUI

actor ThemeForestPlugin: SuperPlugin {
    static let shared = ThemeForestPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 122 }

    nonisolated var title: String { String(localized: "Forest Green", table: "Theme-Forest") }
    nonisolated var description: String { String(localized: "Long listening theme", table: "Theme-Forest") }
    let iconName = "leaf.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: ForestTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
