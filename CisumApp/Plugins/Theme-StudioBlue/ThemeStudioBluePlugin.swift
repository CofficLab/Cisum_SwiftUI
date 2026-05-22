import CisumUI
import Foundation
import SwiftUI

actor ThemeStudioBluePlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 129 }

    let title = "Studio Blue"
    let description = "录音室蓝灰主题"
    let iconName = "waveform"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: StudioBlueTheme())]
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
