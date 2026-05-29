import PluginAudioDownload
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioDownloadPluginInfo.iconName == "icloud.and.arrow.down")
    #expect(AudioDownloadPluginInfo.order == 2)
}
