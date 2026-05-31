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
        requestedModeRawValue: "shuffle",
        currentMode: .shuffle
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        requestedModeRawValue: "shuffle",
        currentMode: .sequence
    ))
    #expect(!AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
        requestedModeRawValue: "invalid",
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
