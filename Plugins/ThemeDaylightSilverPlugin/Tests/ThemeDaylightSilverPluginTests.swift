import Testing
@testable import ThemeDaylightSilverPlugin

@Test func themeIdentityIsStable() {
    let theme = DaylightSilverTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
