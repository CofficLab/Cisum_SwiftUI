import CisumUI
import Foundation
import SwiftUI

actor ThemeOceanPlugin: SuperPlugin {
    static let shared = ThemeOceanPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 123 }

    nonisolated var title: String { String(localized: "Ocean Blue", table: "Theme-Ocean") }
    nonisolated var description: String { String(localized: "Fresh blue-cyan theme", table: "Theme-Ocean") }
    let iconName = "water.waves"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: OceanTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
