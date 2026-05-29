import PluginBookScene
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookScenePluginInfo.iconName == "book.closed")
    #expect(BookScenePluginInfo.sceneName == "Audiobooks")
    #expect(BookScenePluginInfo.order == 0)
}
