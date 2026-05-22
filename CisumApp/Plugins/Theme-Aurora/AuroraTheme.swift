import CisumUI
import SwiftUI

struct AuroraTheme: LumiAppChromeTheme {
    let identifier = "aurora"
    let displayName = "极光紫"
    let description = "低饱和紫色点缀，保留轻盈空间感"
    let iconName = "sparkles"
    let iconColor = Color.adaptive(light: "8B5CF6", dark: "C084FC")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "AF52DE", dark: "BF5AF2"),
            .adaptive(light: "5E5CE6", dark: "5E5CE6"),
            .adaptive(light: "64D2FF", dark: "64D2FF")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F7F5FA", dark: "100E14"),
            .adaptive(light: "FFFFFF", dark: "19171F"),
            .adaptive(light: "F1EEF6", dark: "24212D")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.05), accents.secondary.opacity(0.08), accents.tertiary.opacity(0.12))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "1D1D1F", dark: "F5F5F7") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "515154", dark: "A1A1A6") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "86868B", dark: "74747A") }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        let colors = atmosphereColors()
        let accents = accentColors()
        return AnyView(
            ZStack {
                LinearGradient(colors: [colors.medium, colors.deep, colors.light], startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [accents.primary.opacity(0.10), Color.clear], center: .topTrailing, startRadius: 0, endRadius: 560)
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
