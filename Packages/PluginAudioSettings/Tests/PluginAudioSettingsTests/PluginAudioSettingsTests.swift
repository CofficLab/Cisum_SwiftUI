import PluginAudioSettings
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioSettingsPluginInfo.iconName == "gearshape")
    #expect(AudioSettingsPluginInfo.order == 10)
}
