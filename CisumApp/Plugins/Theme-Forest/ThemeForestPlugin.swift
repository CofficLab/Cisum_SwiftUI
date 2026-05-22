import CisumUI
import Foundation
import SwiftUI

actor ThemeForestPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 122 }

    let title = "森林绿"
    let description = "长时间听书主题"
    let iconName = "leaf.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: ForestTheme(), editorThemeId: "forest")]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

