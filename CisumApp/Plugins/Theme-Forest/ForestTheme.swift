import CisumUI
import SwiftUI

struct ForestTheme: LumiAppChromeTheme {
    let identifier = "forest"
    let displayName = "森林绿"
    let compactName = "森林"
    let description = "安静低饱和绿色，适合长时间听书"
    let iconName = "leaf.fill"
    let iconColor = Color.adaptive(light: "059669", dark: "34D399")
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "059669", dark: "34D399"),
            .adaptive(light: "65A30D", dark: "A3E635"),
            .adaptive(light: "0D9488", dark: "2DD4BF")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "ECFDF5", dark: "07130D"),
            .adaptive(light: "FFFFFF", dark: "102018"),
            .adaptive(light: "D1FAE5", dark: "1B3225")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "052E16", dark: "F0FDF4") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "14532D", dark: "BBF7D0") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "16A34A", dark: "86EFAC") }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
