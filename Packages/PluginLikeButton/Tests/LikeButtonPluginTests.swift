import Testing
@testable import LikeButtonPlugin

@Test func pluginMetadataIsStable() {
    #expect(LikeButtonPluginInfo.toolbarItemId == "like-toggle")
    #expect(!LikeButtonPluginInfo.description.isEmpty)
    #expect(!LikeButtonPluginInfo.iconName.isEmpty)
}
