import PluginAudioPlayMode
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioPlayModePluginInfo.iconName == "repeat")
    #expect(AudioPlayModePluginInfo.emoji == "🔄")
    #expect(AudioPlayModePluginInfo.order == 0)
}
