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
