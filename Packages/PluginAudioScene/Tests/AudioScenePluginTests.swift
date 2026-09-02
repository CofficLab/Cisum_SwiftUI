import AudioScenePlugin
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioScenePluginInfo.iconName == "music.note.list")
    #expect(AudioScenePluginInfo.sceneName == "Music Library")
    #expect(AudioScenePluginInfo.order == 0)
}
