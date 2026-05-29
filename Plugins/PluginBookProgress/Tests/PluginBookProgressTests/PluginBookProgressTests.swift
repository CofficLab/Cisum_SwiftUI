import PluginBookProgress
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookProgressPluginInfo.iconName == "book.closed")
    #expect(BookProgressPluginInfo.order == 5)
}
