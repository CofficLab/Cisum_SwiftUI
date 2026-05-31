import MagicPlayMan
import Testing
@testable import PluginAudioPlayMode

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioPlayModePluginInfo.iconName == "repeat")
    #expect(AudioPlayModePluginInfo.emoji == "🔄")
    #expect(AudioPlayModePluginInfo.order == 0)
}

@Test func queueUpdateOnlyAppliesToStillCurrentPlayMode() {
    #expect(AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .shuffle
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        currentGeneration: 3,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .shuffle
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .sequence
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedModeRawValue: "invalid",
        currentMode: .sequence
    ))
}

@Test func staleQueueUpdateFailureDoesNotReportAfterModeChanges() {
    #expect(AudioPlayModeQueueUpdatePolicy.shouldReportQueueUpdateFailure(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .shuffle
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldReportQueueUpdateFailure(
        currentGeneration: 3,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .shuffle
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldReportQueueUpdateFailure(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .sequence
    ))
}

@Test func audioPlayModeRestoreOnlyAppliesInActiveSceneWhenDifferent() {
    #expect(AudioPlayModeQueueUpdatePolicy.shouldRestorePlayMode(
        isActiveScene: true,
        storedMode: .shuffle,
        currentMode: .sequence
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldRestorePlayMode(
        isActiveScene: false,
        storedMode: .shuffle,
        currentMode: .sequence
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldRestorePlayMode(
        isActiveScene: true,
        storedMode: .shuffle,
        currentMode: .shuffle
    ))
}

@Test func audioPlayModeStoreOnlyAppliesLatestChangeGeneration() {
    #expect(AudioPlayModeQueueUpdatePolicy.shouldStorePlayModeChange(
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldStorePlayModeChange(
        currentGeneration: 3,
        requestGeneration: 2
    ))
}

@Test func audioPlayModeDeactivationInvalidatesPendingChanges() {
    let generation = AudioPlayModeQueueUpdatePolicy.generationAfterDeactivation(2)

    #expect(generation == 3)
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldStorePlayModeChange(
        currentGeneration: generation,
        requestGeneration: 2
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        currentGeneration: generation,
        requestGeneration: 2,
        requestedModeRawValue: "shuffle",
        currentMode: .shuffle
    ))
}

@Test func audioPlayModeFallsBackToCloudWhenLocalValueIsInvalid() {
    #expect(AudioPlayModeStore.resolvedPlayMode(
        localRawValue: "invalid",
        cloudRawValue: MagicPlayMode.shuffle.rawValue
    ) == .shuffle)
}

@Test func audioPlayModeDefaultsWhenStoredValuesAreInvalid() {
    #expect(AudioPlayModeStore.resolvedPlayMode(
        localRawValue: "invalid",
        cloudRawValue: "also-invalid"
    ) == .sequence)
}
