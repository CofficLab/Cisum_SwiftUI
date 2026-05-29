import PluginAudioLike
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioLikePluginInfo.iconName == "heart")
    #expect(AudioLikePluginInfo.emoji == "❤️")
    #expect(AudioLikePluginInfo.order == 3)
}
