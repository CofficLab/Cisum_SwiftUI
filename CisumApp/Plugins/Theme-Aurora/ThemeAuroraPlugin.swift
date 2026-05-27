import CisumUI
import Foundation
import SwiftUI

actor ThemeAuroraPlugin: SuperPlugin {
    static let shared = ThemeAuroraPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 120 }

    let title = "极光紫"
    let description = "沉浸式播放主题"
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
