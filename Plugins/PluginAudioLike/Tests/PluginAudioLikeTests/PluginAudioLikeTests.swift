import PluginAudioLike
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioLikePluginInfo.iconName == "heart")
    #expect(AudioLikePluginInfo.emoji == "❤️")
    #expect(AudioLikePluginInfo.order == 3)
}

@Test
@MainActor
func pluginExposesSettingsView() {
    let view = AudioLikePlugin.shared.addSettingView()

    #expect(view != nil)
}
