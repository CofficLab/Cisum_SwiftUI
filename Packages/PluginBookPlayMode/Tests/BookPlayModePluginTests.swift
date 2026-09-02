import MagicPlayMan
import Testing
@testable import BookPlayModePlugin

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookPlayModePluginInfo.iconName == "repeat")
    #expect(BookPlayModePluginInfo.order == 7)
}

@Test func bookPlayModeRestoreOnlyAppliesInActiveSceneWhenDifferent() {
    #expect(BookPlayModeRestorePolicy.shouldRestorePlayMode(
        currentGeneration: 2,
        requestGeneration: 2,
        isActiveScene: true,
        storedMode: .loop,
        currentMode: .sequence
    ))
    #expect(!BookPlayModeRestorePolicy.shouldRestorePlayMode(
        currentGeneration: 2,
        requestGeneration: 2,
        isActiveScene: false,
        storedMode: .loop,
        currentMode: .sequence
    ))
    #expect(!BookPlayModeRestorePolicy.shouldRestorePlayMode(
        currentGeneration: 2,
        requestGeneration: 2,
        isActiveScene: true,
        storedMode: .loop,
        currentMode: .loop
    ))
    #expect(!BookPlayModeRestorePolicy.shouldRestorePlayMode(
        currentGeneration: 3,
        requestGeneration: 2,
        isActiveScene: true,
        storedMode: .loop,
        currentMode: .sequence
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

@Test func bookPlayModeDeactivationInvalidatesPendingChanges() {
    let generation = BookPlayModeRestorePolicy.generationAfterDeactivation(2)

    #expect(generation == 3)
    #expect(!BookPlayModeRestorePolicy.shouldStorePlayModeChange(
        currentGeneration: generation,
        requestGeneration: 2
    ))
    #expect(!BookPlayModeRestorePolicy.shouldRestorePlayMode(
        currentGeneration: generation,
        requestGeneration: 2,
        isActiveScene: true,
        storedMode: .loop,
        currentMode: .sequence
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
