import Testing
@testable import ThemeOceanPlugin

@Test func themeIdentityIsStable() {
    let theme = OceanTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
