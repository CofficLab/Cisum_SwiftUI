import CisumUI
import Foundation
import SwiftUI

actor ThemeGraphiteBlackPlugin: SuperPlugin {
    static let shared = ThemeGraphiteBlackPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 127 }

    let title = "石墨黑"
    let description = "中性深色主题"
    let iconName = "circle.lefthalf.filled"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: GraphiteBlackTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
