import Testing
@testable import ThemeNebulaPlugin

@Test func themeIdentityIsStable() {
    let theme = NebulaTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
