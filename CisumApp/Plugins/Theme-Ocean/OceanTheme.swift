import CisumUI
import SwiftUI

struct OceanTheme: LumiAppChromeTheme {
    let identifier = "ocean"
    let displayName = "海洋蓝"
    let description = "清爽蓝青点缀，随系统明暗适配"
    let iconName = "water.waves"
    let iconColor = Color.adaptive(light: "0284C7", dark: "38BDF8")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "007AFF", dark: "0A84FF"),
            .adaptive(light: "30B0C7", dark: "40CBE0"),
            .adaptive(light: "64D2FF", dark: "64D2FF")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F2F8FA", dark: "091015"),
            .adaptive(light: "FFFFFF", dark: "141B20"),
            .adaptive(light: "EAF3F7", dark: "202930")
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
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .ignoresSafeArea()
        )
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
