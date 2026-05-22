import CisumUI
import Foundation
import SwiftUI

actor ThemeSunsetPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 124 }

    let title = "日落橙"
    let description = "暖色点缀主题"
    let iconName = "sunset.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: SunsetTheme(), editorThemeId: "sunset")]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

