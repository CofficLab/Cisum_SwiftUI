import CisumUI
import Foundation
import SwiftUI

actor ThemeNebulaPlugin: SuperPlugin {
    static let shared = ThemeNebulaPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 121 }

    let title = "星云粉"
    let description = "柔和暖色主题"
    let iconName = "cloud.moon.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: NebulaTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
