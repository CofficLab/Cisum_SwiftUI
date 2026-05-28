import Testing
@testable import PluginAudioCopy

@Test func audioCopyInfoExportsMetadata() {
    #expect(AudioCopyPluginInfo.iconName == "music.note")
    #expect(AudioCopyPluginInfo.table == "Audio-Copy-macOS")
}
