import CisumUI
import SwiftUI

struct SunsetTheme: LumiAppChromeTheme {
    let identifier = "sunset"
    let displayName = "日落橙"
    let description = "暖色点缀主题，避免大面积高饱和"
    let iconName = "sunset.fill"
    let iconColor = Color.adaptive(light: "EA580C", dark: "FB923C")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "EA580C", dark: "FB923C"),
            .adaptive(light: "E11D48", dark: "F43F5E"),
            .adaptive(light: "CA8A04", dark: "FACC15")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "FFF7ED", dark: "1C1008"),
            .adaptive(light: "FFFFFF", dark: "26180F"),
            .adaptive(light: "FFEDD5", dark: "3A2416")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "431407", dark: "FFF7ED") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "7C2D12", dark: "FED7AA") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "EA580C", dark: "FDBA74") }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        let colors = atmosphereColors()
        return AnyView(
            LinearGradient(
                colors: [colors.deep, colors.medium, colors.light],
                startPoint: .top,
                endPoint: .bottom
            )
            .background(.ultraThinMaterial)
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
