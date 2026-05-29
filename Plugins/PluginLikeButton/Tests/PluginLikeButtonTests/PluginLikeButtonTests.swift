import Testing
@testable import PluginLikeButton

@Test func pluginMetadataIsStable() {
    #expect(LikeButtonPluginInfo.toolbarItemId == "like-toggle")
    #expect(!LikeButtonPluginInfo.description.isEmpty)
    #expect(!LikeButtonPluginInfo.iconName.isEmpty)
}
