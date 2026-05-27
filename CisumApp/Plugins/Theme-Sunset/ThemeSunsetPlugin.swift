import CisumUI
import Foundation
import SwiftUI

actor ThemeSunsetPlugin: SuperPlugin {
    static let shared = ThemeSunsetPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 124 }

    let title = "日落橙"
    let description = "暖色点缀主题"
    let iconName = "sunset.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: SunsetTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
