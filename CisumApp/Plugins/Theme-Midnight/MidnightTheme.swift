import CisumUI
import SwiftUI

struct MidnightTheme: LumiAppChromeTheme {
    let identifier = "midnight"
    let displayName = "午夜幽蓝"
    let compactName = "午夜"
    let description = "低亮度蓝黑背景，适合夜间听歌"
    let iconName = "moon.stars.fill"
    let iconColor = Color.adaptive(light: "2563EB", dark: "60A5FA")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "2563EB", dark: "60A5FA"),
            .adaptive(light: "4F46E5", dark: "818CF8"),
            .adaptive(light: "0891B2", dark: "22D3EE")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "EFF6FF", dark: "020617"),
            .adaptive(light: "FFFFFF", dark: "0F172A"),
            .adaptive(light: "DBEAFE", dark: "1E293B")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "0F172A", dark: "F8FAFC") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "334155", dark: "CBD5E1") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "64748B", dark: "64748B") }

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
