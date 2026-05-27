import CisumUI
import Foundation
import SwiftUI

actor ThemeOceanPlugin: SuperPlugin {
    static let shared = ThemeOceanPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 123 }

    let title = "海洋蓝"
    let description = "清爽蓝青主题"
    let iconName = "water.waves"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: OceanTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
