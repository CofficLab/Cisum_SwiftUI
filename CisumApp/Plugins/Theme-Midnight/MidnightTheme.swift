import CisumUI
import SwiftUI

struct MidnightTheme: LumiAppChromeTheme {
    let identifier = "midnight"
    let displayName = "午夜幽蓝"
    let description = "深灰空间与蓝色点缀，适合夜间听歌"
    let iconName = "moon.stars.fill"
    let iconColor = Color.adaptive(light: "2563EB", dark: "60A5FA")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "2563EB", dark: "60A5FA"),
            .adaptive(light: "007AFF", dark: "0A84FF"),
            .adaptive(light: "5AC8FA", dark: "64D2FF")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F5F7FA", dark: "090B10"),
            .adaptive(light: "FFFFFF", dark: "14171D"),
            .adaptive(light: "EEF3FA", dark: "20242C")
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
