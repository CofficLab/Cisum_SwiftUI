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
