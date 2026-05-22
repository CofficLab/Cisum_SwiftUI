import AppKit
import SwiftUI
import Testing
@testable import LumiUI

private struct TestTheme: LumiUITheme {
    let id = "test-theme"
    let name = "Test Theme"

    let primary = Color.red
    let primarySecondary = Color.orange

    let textPrimary = Color.black
    let textSecondary = Color.gray
    let textTertiary = Color.secondary
    let textDisabled = Color.gray.opacity(0.5)

    let background = Color.white
    let surface = Color.white
    let elevatedSurface = Color.white
    let overlay = Color.gray.opacity(0.1)
    let divider = Color.gray.opacity(0.2)

    let success = Color.green
    let warning = Color.yellow
    let error = Color.red
    let info = Color.blue
}

struct LumiUIThemeTests {
    @Test
    @MainActor
    func defaultThemeIsAvailable() {
        LumiUI.setTheme(LumiDefaultTheme())

        #expect(LumiUI.currentTheme.id == "lumi-default")
        #expect(LumiUI.currentTheme.name == "Lumi Default")
    }

    @Test
    @MainActor
    func setThemeReplacesCurrentTheme() {
        LumiUI.setTheme(TestTheme())
        defer { LumiUI.setTheme(LumiDefaultTheme()) }

        #expect(LumiUI.currentTheme.id == "test-theme")
        #expect(LumiUI.currentTheme.name == "Test Theme")
    }

    @Test
    @MainActor
    func protocolExtensionFillsInGlowAndGlowAccentDefaults() {
        let theme = TestTheme()

        // TestTheme intentionally omits successGlow/warningGlow/errorGlow/infoGlow,
        // which makes the protocol extension defaults apply.
        let success = NSColor(theme.successGlow).usingColorSpace(.sRGB)
        let warning = NSColor(theme.warningGlow).usingColorSpace(.sRGB)
        let error = NSColor(theme.errorGlow).usingColorSpace(.sRGB)
        let info = NSColor(theme.infoGlow).usingColorSpace(.sRGB)

        #expect(abs((success?.alphaComponent ?? 0) - 0.65) < 0.01)
        #expect(abs((warning?.alphaComponent ?? 0) - 0.65) < 0.01)
        #expect(abs((error?.alphaComponent ?? 0) - 0.65) < 0.01)
        #expect(abs((info?.alphaComponent ?? 0) - 0.65) < 0.01)

        let glowAccentNSColor = NSColor(theme.glowAccent).usingColorSpace(.sRGB)
        let primaryNSColor = NSColor(theme.primary).usingColorSpace(.sRGB)
        #expect(abs((glowAccentNSColor?.redComponent ?? 0) - (primaryNSColor?.redComponent ?? 1)) < 0.01)
    }

    @Test
    @MainActor
    func protocolExtensionGradientDefaultsAreAccessibleWithoutCrash() {
        let theme = TestTheme()

        // Just exercise the gradient computed properties; the goal is to cover
        // the LinearGradient fall-through paths in LumiUITheme.
        _ = theme.primaryGradient
        _ = theme.oceanGradient
        _ = theme.auroraGradient
        _ = theme.energyGradient
        _ = theme.glowBorderGradient
    }

    @Test
    @MainActor
    func lumiThemePropertyWrapperReflectsCurrentStore() {
        LumiUI.setTheme(TestTheme())
        defer { LumiUI.setTheme(LumiDefaultTheme()) }

        let wrapper = LumiTheme()
        #expect(wrapper.wrappedValue.id == "test-theme")
    }

    @Test
    @MainActor
    func lumiDefaultThemeExposesExpectedIdentifiers() {
        let theme = LumiDefaultTheme()

        #expect(theme.id == "lumi-default")
        #expect(theme.name == "Lumi Default")
    }
}
