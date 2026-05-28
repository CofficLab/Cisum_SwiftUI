import Testing
@testable import PluginAudioProgress

@Test func audioProgressInfoExportsMetadata() {
    #expect(AudioProgressPluginInfo.titleKey == "Audio Progress")
    #expect(AudioProgressPluginInfo.table == "Audio-Progress")
}
