import MagicPlayMan
import Testing
@testable import PluginBookPlayMode

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookPlayModePluginInfo.iconName == "repeat")
    #expect(BookPlayModePluginInfo.order == 7)
}

@Test func bookPlayModeRestoreOnlyAppliesInActiveSceneWhenDifferent() {
    #expect(BookPlayModeRestorePolicy.shouldRestorePlayMode(
        isActiveScene: true,
        storedMode: .loop,
        currentMode: .sequence
    ))
    #expect(!BookPlayModeRestorePolicy.shouldRestorePlayMode(
        isActiveScene: false,
        storedMode: .loop,
        currentMode: .sequence
    ))
    #expect(!BookPlayModeRestorePolicy.shouldRestorePlayMode(
        isActiveScene: true,
        storedMode: .loop,
        currentMode: .loop
    ))
}
