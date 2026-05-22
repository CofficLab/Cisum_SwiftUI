import CisumUI
import SwiftUI

struct PaperTheme: LumiAppChromeTheme {
    let identifier = "paper"
    let displayName = "Paper"
    let description = "纸张暖白背景，适合有声书"
    let iconName = "book.closed.fill"
    let iconColor = Color.adaptive(light: "A15C38", dark: "D8A06B")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "A15C38", dark: "D8A06B"),
            .adaptive(light: "8E6F4E", dark: "BFA27A"),
            .adaptive(light: "4C6A58", dark: "7FA08B")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F4F0E8", dark: "141210"),
            .adaptive(light: "FFFCF6", dark: "211E1A"),
            .adaptive(light: "E9E1D4", dark: "312B25")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.05), accents.secondary.opacity(0.08), accents.tertiary.opacity(0.10))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "231F1A", dark: "F7F0E6") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "5E554B", dark: "C7B9A7") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "8B8175", dark: "9E9184") }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        let colors = atmosphereColors()
        let accents = accentColors()
        return AnyView(
            ZStack {
                LinearGradient(colors: [colors.medium, colors.deep, colors.light], startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [accents.primary.opacity(0.08), Color.clear], center: .topLeading, startRadius: 0, endRadius: 520)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
        )
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
