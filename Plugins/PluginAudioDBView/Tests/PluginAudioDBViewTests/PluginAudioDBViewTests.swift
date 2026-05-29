import Testing
@testable import PluginAudioDBView

@Test func audioDBInfoExportsMetadata() {
    #expect(AudioDBPluginInfo.titleKey == "Audio Repository")
    #expect(AudioDBPluginInfo.table == "Audio-DBView")
}
