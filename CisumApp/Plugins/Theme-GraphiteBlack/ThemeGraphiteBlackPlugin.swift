import CisumUI
import Foundation
import SwiftUI

actor ThemeGraphiteBlackPlugin: SuperPlugin {
    static let shared = ThemeGraphiteBlackPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 127 }

    nonisolated var title: String { String(localized: "Graphite Black", table: "Theme-GraphiteBlack") }
    nonisolated var description: String { String(localized: "Neutral dark theme", table: "Theme-GraphiteBlack") }
    let iconName = "circle.lefthalf.filled"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: GraphiteBlackTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
