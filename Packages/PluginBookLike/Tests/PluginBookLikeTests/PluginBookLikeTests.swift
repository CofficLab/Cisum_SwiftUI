import PluginBookLike
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookLikePluginInfo.iconName == "heart")
    #expect(BookLikePluginInfo.order == 6)
}
