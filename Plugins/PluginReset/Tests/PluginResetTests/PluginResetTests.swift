import PluginReset
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(ResetPluginInfo.iconName == "gearshape")
    #expect(ResetPluginInfo.emoji == "⚙️")
    #expect(ResetPluginInfo.order == 90)
}
