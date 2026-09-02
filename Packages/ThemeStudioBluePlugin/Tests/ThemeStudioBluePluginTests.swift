import Testing
@testable import ThemeStudioBluePlugin

@Test func themeIdentityIsStable() {
    let theme = StudioBlueTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
