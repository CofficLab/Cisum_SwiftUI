import CisumUI
import Foundation
import SwiftUI

actor ThemeMonoPlugin: SuperPlugin {
    static let shared = ThemeMonoPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 125 }

    nonisolated var title: String { String(localized: "Mono High Contrast", table: "Theme-Mono") }
    nonisolated var description: String { String(localized: "Readability-first theme", table: "Theme-Mono") }
    let iconName = "circle.lefthalf.filled"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MonoTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
