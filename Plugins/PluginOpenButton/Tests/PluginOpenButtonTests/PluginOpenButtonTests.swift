import Testing
@testable import PluginOpenButton

@Test func pluginMetadataIsStable() {
    #expect(OpenButtonPluginInfo.toolbarItemId == "open-current")
    #expect(!OpenButtonPluginInfo.description.isEmpty)
    #expect(!OpenButtonPluginInfo.iconName.isEmpty)
}
