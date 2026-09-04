import Testing
@testable import ThemeMonoPlugin

@Test func themeIdentityIsStable() {
    let theme = MonoTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
