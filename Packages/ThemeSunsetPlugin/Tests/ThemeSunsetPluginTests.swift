import Testing
@testable import ThemeSunsetPlugin

@Test func themeIdentityIsStable() {
    let theme = SunsetTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
