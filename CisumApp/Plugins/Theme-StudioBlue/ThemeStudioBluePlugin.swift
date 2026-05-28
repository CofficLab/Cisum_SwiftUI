import CisumUI
import Foundation
import SwiftUI

actor ThemeStudioBluePlugin: SuperPlugin {
    static let shared = ThemeStudioBluePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 129 }

    nonisolated var title: String { String(localized: "Studio Blue", table: "Theme-StudioBlue") }
    nonisolated var description: String { String(localized: "Studio blue-gray theme", table: "Theme-StudioBlue") }
    let iconName = "waveform"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: StudioBlueTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
