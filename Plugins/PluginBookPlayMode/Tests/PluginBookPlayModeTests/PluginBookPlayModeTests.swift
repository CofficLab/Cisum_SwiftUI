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

@Test func bookPlayModeStoreOnlyAppliesLatestChangeGeneration() {
    #expect(BookPlayModeRestorePolicy.shouldStorePlayModeChange(
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!BookPlayModeRestorePolicy.shouldStorePlayModeChange(
        currentGeneration: 3,
        requestGeneration: 2
    ))
}

@Test func bookPlayModeFallsBackToCloudWhenLocalValueIsInvalid() {
    #expect(BookPlayModeStore.resolvedPlayMode(
        localRawValue: "invalid",
        cloudRawValue: MagicPlayMode.loop.rawValue
    ) == .loop)
}

@Test func bookPlayModeDefaultsWhenStoredValuesAreInvalid() {
    #expect(BookPlayModeStore.resolvedPlayMode(
        localRawValue: "invalid",
        cloudRawValue: "also-invalid"
    ) == .sequence)
}
