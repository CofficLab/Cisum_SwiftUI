import CisumUI
import Foundation
import SwiftUI

actor ThemeMonoPlugin: SuperPlugin {
    static let shared = ThemeMonoPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 125 }

    let title = "黑白高对比"
    let description = "可读性优先主题"
    let iconName = "circle.lefthalf.filled"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MonoTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
