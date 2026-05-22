import CisumUI
import Foundation
import SwiftUI

actor ThemeCisumPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 118 }

    let title = "Cisum"
    let description = "Cisum 默认主题"
    let iconName = "circle.hexagonpath.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
