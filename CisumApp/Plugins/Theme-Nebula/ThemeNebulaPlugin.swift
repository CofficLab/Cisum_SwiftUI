import CisumUI
import Foundation
import SwiftUI

actor ThemeNebulaPlugin: SuperPlugin {
    static let shared = ThemeNebulaPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 121 }

    nonisolated var title: String { String(localized: "Nebula Pink", table: "Theme-Nebula") }
    nonisolated var description: String { String(localized: "Soft warm theme", table: "Theme-Nebula") }
    let iconName = "cloud.moon.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: NebulaTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
