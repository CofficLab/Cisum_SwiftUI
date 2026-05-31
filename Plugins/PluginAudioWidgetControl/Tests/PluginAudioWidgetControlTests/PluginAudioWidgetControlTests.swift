import Foundation
import Testing
@testable import PluginAudioWidgetControl

@Test func pluginMetadataIsStable() {
    #expect(AudioWidgetControlPluginInfo.iconName == "command")
    #expect(!AudioWidgetControlPluginInfo.title.isEmpty)
    #expect(!AudioWidgetControlPluginInfo.description.isEmpty)
}

@Test func navigationResultOnlyAppliesToUnchangedCurrentAsset() {
    let requested = URL(fileURLWithPath: "/tmp/requested.mp3")
    let switched = URL(fileURLWithPath: "/tmp/switched.mp3")

    #expect(AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested
    ))
    #expect(!AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched
    ))
    #expect(!AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: nil
    ))
}

@Test func widgetCommandCountPreservesRapidRepeatedCommands() {
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: 3) == 3)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: NSNumber(value: 3)) == 3)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: 0) == 0)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: -2) == 0)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: 99) == 10)
}

@Test func widgetCommandCountAcceptsLegacyTimestampTrigger() {
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: TimeInterval(1_700_000_000)) == 1)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: NSNumber(value: 1_700_000_000.0)) == 1)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: nil) == 0)
    #expect(AudioWidgetPlaybackRequestPolicy.commandCount(from: "unexpected") == 0)
}

@Test func widgetCommandConsumptionPreservesCommandsAddedDuringHandling() {
    #expect(AudioWidgetPlaybackRequestPolicy.remainingCommandCount(
        afterConsuming: 1,
        storedValue: NSNumber(value: 1)
    ) == 0)
    #expect(AudioWidgetPlaybackRequestPolicy.remainingCommandCount(
        afterConsuming: 1,
        storedValue: NSNumber(value: 2)
    ) == 1)
    #expect(AudioWidgetPlaybackRequestPolicy.remainingCommandCount(
        afterConsuming: 3,
        storedValue: NSNumber(value: 2)
    ) == 0)
}
