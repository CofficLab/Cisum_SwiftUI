import Testing
@testable import PluginAudioDemo

@Test func pluginMetadataIsStable() {
    #expect(AudioDemoPluginInfo.iconName == "externaldrive")
    #expect(!AudioDemoPluginInfo.title.isEmpty)
    #expect(!AudioDemoPluginInfo.description.isEmpty)
    #expect(!AudioDemoPluginInfo.tabLabel.isEmpty)
}

@MainActor
@Test func demoAudioFilesAreAvailable() {
    #expect(AudioListDemo.demoAudioFiles.count == 20)
    #expect(AudioItemDemo.iconNames.count == 8)
}
