import CisumUI
import Foundation
import SwiftUI

actor ThemeMidnightPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 119 }

    let title = "午夜幽蓝"
    let description = "夜间听歌主题"
    let iconName = "moon.stars.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MidnightTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
