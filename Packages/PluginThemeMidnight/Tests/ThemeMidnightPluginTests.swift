import Testing
@testable import ThemeMidnightPlugin

@Test func themeIdentityIsStable() {
    let theme = MidnightTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
