import CisumUI
import Foundation
import SwiftUI

actor ThemePaperPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 128 }

    let title = "Paper"
    let description = "有声书阅读主题"
    let iconName = "book.closed.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: PaperTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
