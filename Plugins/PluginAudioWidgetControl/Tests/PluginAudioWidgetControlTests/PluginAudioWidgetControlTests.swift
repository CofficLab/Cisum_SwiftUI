import Testing
@testable import PluginAudioWidgetControl

@Test func pluginMetadataIsStable() {
    #expect(AudioWidgetControlPluginInfo.iconName == "command")
    #expect(!AudioWidgetControlPluginInfo.title.isEmpty)
    #expect(!AudioWidgetControlPluginInfo.description.isEmpty)
}
