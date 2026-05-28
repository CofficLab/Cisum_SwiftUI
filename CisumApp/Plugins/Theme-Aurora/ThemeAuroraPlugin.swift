import CisumUI
import Foundation
import SwiftUI

actor ThemeAuroraPlugin: SuperPlugin {
    static let shared = ThemeAuroraPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 120 }

    nonisolated var title: String { String(localized: "Aurora Purple", table: "Theme-Aurora") }
    nonisolated var description: String { String(localized: "Immersive playback theme", table: "Theme-Aurora") }
    let iconName = "sparkles"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: AuroraTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
