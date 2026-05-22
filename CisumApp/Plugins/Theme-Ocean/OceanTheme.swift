import CisumUI
import SwiftUI

struct OceanTheme: LumiAppChromeTheme {
    let identifier = "ocean"
    let displayName = "海洋蓝"
    let description = "清爽蓝青配色，随系统明暗适配"
    let iconName = "water.waves"
    let iconColor = Color.adaptive(light: "0284C7", dark: "38BDF8")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "0284C7", dark: "38BDF8"),
            .adaptive(light: "0D9488", dark: "2DD4BF"),
            .adaptive(light: "2563EB", dark: "60A5FA")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "E0F2FE", dark: "061826"),
            .adaptive(light: "F8FAFC", dark: "0C2433"),
            .adaptive(light: "BAE6FD", dark: "14384A")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "0F172A", dark: "F0F9FF") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "334155", dark: "BAE6FD") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "64748B", dark: "7DD3FC") }

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
