import CisumUI
import SwiftUI

struct NebulaTheme: LumiAppChromeTheme {
    let identifier = "nebula"
    let displayName = "星云粉"
    let description = "柔和粉紫氛围，保留清晰文本对比"
    let iconName = "cloud.moon.fill"
    let iconColor = Color.adaptive(light: "C026D3", dark: "F0ABFC")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "C026D3", dark: "F0ABFC"),
            .adaptive(light: "E11D48", dark: "FB7185"),
            .adaptive(light: "7C3AED", dark: "C4B5FD")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "FDF4FF", dark: "1E1024"),
            .adaptive(light: "FFFFFF", dark: "2A1733"),
            .adaptive(light: "FAE8FF", dark: "3B2247")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "4A044E", dark: "FDF4FF") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "86198F", dark: "F5D0FE") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "C026D3", dark: "C084FC") }

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
