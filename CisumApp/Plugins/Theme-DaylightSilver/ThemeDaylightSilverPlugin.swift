import CisumUI
import Foundation
import SwiftUI

actor ThemeDaylightSilverPlugin: SuperPlugin {
    static let shared = ThemeDaylightSilverPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 126 }

    let title = "白昼银"
    let description = "白天办公主题"
    let iconName = "sun.max.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: DaylightSilverTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
