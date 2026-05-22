import SwiftUI
import Testing
@testable import LumiUI

private struct ChromeFixture: LumiAppChromeTheme {
    let identifier = "fixture"
    let displayName = "Fixture"
    let compactName = "Fix"
    let description = "Test"
    let iconName = "star"
    let iconColor = Color.red

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (.red, .orange, .yellow)
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (Color(hex: "111111"), Color(hex: "222222"), Color(hex: "333333"))
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        (.red, .red, .red)
    }

    func workspaceTextColor() -> Color { Color(hex: "AABBCC") }
    func workspaceSecondaryTextColor() -> Color { Color(hex: "DDEEFF") }
    func workspaceTertiaryTextColor() -> Color { Color(hex: "112233") }
}

struct ChromeToUIThemeAdapterTests {
    @Test
    func mapsIdentityAndAccentToUITheme() {
        let chrome = ChromeFixture()
        let ui = ChromeToUIThemeAdapter(chrome: chrome)

        #expect(ui.id == "fixture")
        #expect(ui.name == "Fixture")
        #expect(ui.primary == chrome.accentColors().primary)
        #expect(ui.textPrimary == chrome.workspaceTextColor())
        #expect(ui.background == chrome.atmosphereColors().deep)
        #expect(ui.surface == chrome.atmosphereColors().medium)
    }
}
