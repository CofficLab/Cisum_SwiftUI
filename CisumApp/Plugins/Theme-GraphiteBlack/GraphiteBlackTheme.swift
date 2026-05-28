import CisumUI
import SwiftUI

struct GraphiteBlackTheme: LumiAppChromeTheme {
    let identifier = "graphite-black"
    let displayName = String(localized: "Graphite Black", table: "Theme-GraphiteBlack")
    let description = String(localized: "Neutral black-gray layers, ideal for extended night listening", table: "Theme-GraphiteBlack")
    let iconName = "circle.lefthalf.filled"
    let iconColor = Color.adaptive(light: "3A3A3C", dark: "D1D1D6")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "3A3A3C", dark: "D1D1D6"),
            .adaptive(light: "0A84FF", dark: "64D2FF"),
            .adaptive(light: "6E6E73", dark: "8E8E93")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F5F5F7", dark: "050506"),
            .adaptive(light: "FFFFFF", dark: "121214"),
            .adaptive(light: "E9EAED", dark: "232326")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.04), accents.secondary.opacity(0.07), accents.tertiary.opacity(0.10))
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
                RadialGradient(colors: [accents.secondary.opacity(0.08), Color.clear], center: .topTrailing, startRadius: 0, endRadius: 520)
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
