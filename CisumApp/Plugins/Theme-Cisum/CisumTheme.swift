import CisumUI
import SwiftUI

struct CisumTheme: LumiAppChromeTheme {
    let identifier = "cisum"
    let displayName = String(localized: "Cisum", table: "Theme-Cisum")
    let description = String(localized: "Original sunset gradient color scheme", table: "Theme-Cisum")
    let iconName = "sunset.fill"
    let iconColor = Color.adaptive(light: "FF512F", dark: "FF8A4C")
    let isDarkTheme = false
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "FF512F", dark: "FF8A4C"),
            .adaptive(light: "F09819", dark: "FBBF24"),
            .adaptive(light: "4A90E2", dark: "60A5FA")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            Color.adaptive(light: "FF512F", dark: "2A0E08").opacity(0.18),
            Color.adaptive(light: "F09819", dark: "3A1C0A").opacity(0.18),
            Color.adaptive(light: "FFFFFF", dark: "5A2A12").opacity(0.34)
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (
            accents.primary.opacity(0.12),
            accents.secondary.opacity(0.2),
            accents.tertiary.opacity(0.32)
        )
    }

    func workspaceTextColor() -> Color {
        .adaptive(light: "1C1C1E", dark: "FFFFFF")
    }

    func workspaceSecondaryTextColor() -> Color {
        .adaptive(light: "3A2A22", dark: "F5E6DC")
    }

    func workspaceTertiaryTextColor() -> Color {
        .adaptive(light: "6F5147", dark: "D7B7A5")
    }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        AnyView(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.adaptive(light: "FF512F", dark: "2A0E08").opacity(0.7),
                    Color.adaptive(light: "F09819", dark: "7C2D12").opacity(0.7),
                ]),
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
