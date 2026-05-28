import CisumUI
import Foundation
import SwiftUI

actor ThemePaperPlugin: SuperPlugin {
    static let shared = ThemePaperPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 128 }

    nonisolated var title: String { String(localized: "Paper", table: "Theme-Paper") }
    nonisolated var description: String { String(localized: "Audiobook reading theme", table: "Theme-Paper") }
    let iconName = "book.closed.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: PaperTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
