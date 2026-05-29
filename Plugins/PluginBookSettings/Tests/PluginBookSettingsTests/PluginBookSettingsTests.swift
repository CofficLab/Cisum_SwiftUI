import PluginBookSettings
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookSettingsPluginInfo.iconName == "gearshape")
    #expect(BookSettingsPluginInfo.order == 11)
}
