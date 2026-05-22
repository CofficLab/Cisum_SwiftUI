import SwiftUI
import Testing
@testable import CisumUI

private struct MockChromeTheme: LumiAppChromeTheme {
    let identifier: String
    let displayName: String
    let description: String
    let iconName: String
    let iconColor: Color
    let isDarkTheme: Bool

    init(
        id: String,
        name: String = "Mock",
        pluginTint: Color = .purple,
        isDark: Bool = true
    ) {
        identifier = id
        displayName = name
        description = "Mock theme \(id)"
        iconName = "circle.fill"
        iconColor = pluginTint
        isDarkTheme = isDark
    }

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (iconColor, iconColor.opacity(0.8), iconColor.opacity(0.6))
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (.black, .gray, .white)
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        (iconColor.opacity(0.1), iconColor.opacity(0.2), iconColor.opacity(0.3))
    }
}

private func contribution(
    pluginOrder: Int,
    themeId: String
) -> LumiUIThemeContribution {
    return LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: pluginOrder, themeId: themeId),
        chromeTheme: MockChromeTheme(id: themeId, name: themeId.capitalized)
    )
}

struct LumiUIThemeRegistryTests {
    @Test
    @MainActor
    func replaceAllEmptyThrowsNoThemesRegistered() {
        let registry = LumiUIThemeRegistry()
        #expect(throws: ThemeError.noThemesRegistered) {
            try registry.replaceAll([])
        }
    }

    @Test
    @MainActor
    func replaceAllDuplicateIdThrows() {
        let registry = LumiUIThemeRegistry()
        let a = contribution(pluginOrder: 1, themeId: "same")
        let b = contribution(pluginOrder: 2, themeId: "same")
        #expect(throws: ThemeError.duplicateThemeId("same")) {
            try registry.replaceAll([a, b])
        }
    }

    @Test
    @MainActor
    func defaultThemeIsFirstAfterSort() throws {
        let registry = LumiUIThemeRegistry()
        try registry.replaceAll([
            contribution(pluginOrder: 20, themeId: "zulu"),
            contribution(pluginOrder: 10, themeId: "alpha"),
            contribution(pluginOrder: 10, themeId: "beta"),
        ])
        #expect(registry.selectedThemeId == "alpha")
    }

    @Test
    @MainActor
    func selectUnknownIdThrows() throws {
        let registry = LumiUIThemeRegistry()
        try registry.replaceAll([contribution(pluginOrder: 1, themeId: "only")])
        #expect(throws: ThemeError.unknownThemeId("missing")) {
            try registry.select(themeId: "missing")
        }
    }

    @Test
    @MainActor
    func selectUpdatesChromeAndUIStore() throws {
        let registry = LumiUIThemeRegistry()
        try registry.replaceAll([
            contribution(pluginOrder: 1, themeId: "first"),
            contribution(pluginOrder: 2, themeId: "second"),
        ])
        try registry.select(themeId: "second")
        #expect(registry.chromeTheme.identifier == "second")
        #expect(registry.uiTheme.id == "second")
        #expect(LumiUIThemeStore.shared.theme.id == "second")
    }

    @Test
    @MainActor
    func replaceAllDropsInvalidSelectionToDefault() throws {
        let registry = LumiUIThemeRegistry()
        try registry.replaceAll([
            contribution(pluginOrder: 1, themeId: "a"),
            contribution(pluginOrder: 2, themeId: "b"),
        ])
        try registry.select(themeId: "b")
        try registry.replaceAll([contribution(pluginOrder: 1, themeId: "a")])
        #expect(registry.selectedThemeId == "a")
    }
}
