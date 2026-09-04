import Testing
@testable import ThemeForestPlugin

@Test func themeIdentityIsStable() {
    let theme = ForestTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
