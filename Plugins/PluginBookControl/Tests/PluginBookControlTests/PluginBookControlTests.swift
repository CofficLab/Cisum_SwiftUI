import Testing
import PluginBookControl

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookControlPluginInfo.iconName == "playpause")
    #expect(BookControlPluginInfo.order == 8)
}
