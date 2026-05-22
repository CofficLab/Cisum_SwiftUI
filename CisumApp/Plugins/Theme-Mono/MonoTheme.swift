import CisumUI
import SwiftUI

struct MonoTheme: LumiAppChromeTheme {
    let identifier = "mono"
    let displayName = "黑白高对比"
    let description = "极简灰阶，强调内容本身"
    let iconName = "circle.lefthalf.filled"
    let iconColor = Color.adaptive(light: "111827", dark: "FFFFFF")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "1D1D1F", dark: "F5F5F7"),
            .adaptive(light: "6E6E73", dark: "A1A1A6"),
            .adaptive(light: "8E8E93", dark: "8E8E93")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F5F5F7", dark: "0B0B0F"),
            .adaptive(light: "FFFFFF", dark: "151519"),
            .adaptive(light: "EEEEF0", dark: "202027")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.03), accents.secondary.opacity(0.05), accents.tertiary.opacity(0.08))
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
                RadialGradient(colors: [accents.primary.opacity(0.06), Color.clear], center: .topTrailing, startRadius: 0, endRadius: 560)
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
