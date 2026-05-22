import CisumUI
import SwiftUI

struct MonoTheme: LumiAppChromeTheme {
    let identifier = "mono"
    let displayName = "黑白高对比"
    let compactName = "高对比"
    let description = "黑白对比优先，提升可读性"
    let iconName = "circle.lefthalf.filled"
    let iconColor = Color.adaptive(light: "111827", dark: "FFFFFF")
    let followsSystemAppearance = true

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (
            .adaptive(light: "111827", dark: "FFFFFF"),
            .adaptive(light: "52525B", dark: "D4D4D8"),
            .adaptive(light: "71717A", dark: "A1A1AA")
        )
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (
            .adaptive(light: "F4F4F5", dark: "000000"),
            .adaptive(light: "FFFFFF", dark: "09090B"),
            .adaptive(light: "E4E4E7", dark: "18181B")
        )
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        let accents = accentColors()
        return (accents.primary.opacity(0.12), accents.secondary.opacity(0.2), accents.tertiary.opacity(0.32))
    }

    func workspaceTextColor() -> Color { .adaptive(light: "09090B", dark: "FFFFFF") }
    func workspaceSecondaryTextColor() -> Color { .adaptive(light: "3F3F46", dark: "E4E4E7") }
    func workspaceTertiaryTextColor() -> Color { .adaptive(light: "71717A", dark: "A1A1AA") }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
