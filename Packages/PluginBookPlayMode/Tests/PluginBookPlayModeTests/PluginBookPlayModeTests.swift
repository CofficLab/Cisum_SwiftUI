import Testing
import PluginBookPlayMode

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookPlayModePluginInfo.iconName == "repeat")
    #expect(BookPlayModePluginInfo.order == 7)
}
