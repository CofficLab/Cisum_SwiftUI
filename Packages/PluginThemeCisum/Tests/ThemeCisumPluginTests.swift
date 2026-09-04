import Testing
@testable import PluginThemeCisum

@Test func themeIdentityIsStable() {
    let theme = CisumTheme()
    #expect(!theme.identifier.isEmpty)
    #expect(!theme.displayName.isEmpty)
    #expect(!theme.iconName.isEmpty)
}
