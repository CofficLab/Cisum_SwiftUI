import Testing
@testable import PluginAudioControl

@Test func pluginMetadataIsStable() {
    #expect(AudioControlPluginInfo.iconName == "playpause")
    #expect(!AudioControlPluginInfo.title.isEmpty)
    #expect(!AudioControlPluginInfo.description.isEmpty)
}
