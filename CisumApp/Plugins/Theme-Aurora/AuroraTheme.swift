import CisumUI
import SwiftUI

struct AuroraTheme: LumiAppChromeTheme {
    let identifier = "aurora"
    let displayName = "极光紫"
    let description = "冷紫与青绿交织，适合沉浸式播放页"
    let iconName = "sparkles"
    let iconColor = Color.adaptive(light: "8B5CF6", dark: "C084FC")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "8B5CF6", dark: "A855F7"),
            .adaptive(light: "0891B2", dark: "22D3EE"),
            .adaptive(light: "059669", dark: "34D399")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F5F3FF", dark: "12091F"),
            .adaptive(light: "FFFFFF", dark: "1E1230"),
            .adaptive(light: "EDE9FE", dark: "2F1F46")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "1E1B4B", dark: "FAF5FF") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "4C1D95", dark: "DDD6FE") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "7C3AED", dark: "A78BFA") }

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
