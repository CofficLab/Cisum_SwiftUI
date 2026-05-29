import Testing
@testable import PluginAudio

@Test func audioPluginInfoExportsMetadata() {
    #expect(AudioPluginInfo.titleKey == "Music")
    #expect(AudioPluginInfo.maxAudioCount == 100)
    #expect(AudioPluginInfo.supportedExtensions.contains("mp3"))
}
