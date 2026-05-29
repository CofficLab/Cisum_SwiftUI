import PluginWelcome
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(WelcomePluginInfo.iconName == "hand.wave")
    #expect(WelcomePluginInfo.emoji == "👏")
    #expect(WelcomePluginInfo.order == -100)
}
