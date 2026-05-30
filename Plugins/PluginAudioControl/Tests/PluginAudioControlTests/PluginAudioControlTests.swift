import Foundation
import Testing
@testable import PluginAudioControl

@Test func pluginMetadataIsStable() {
    #expect(AudioControlPluginInfo.iconName == "playpause")
    #expect(!AudioControlPluginInfo.title.isEmpty)
    #expect(!AudioControlPluginInfo.description.isEmpty)
}

@Test func navigationResultOnlyAppliesToUnchangedCurrentAsset() {
    let requested = URL(fileURLWithPath: "/tmp/requested.mp3")
    let switched = URL(fileURLWithPath: "/tmp/switched.mp3")

    #expect(AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: nil
    ))
}

@Test func deletionOnlyAffectsCurrentAssetWhenItIsDeleted() {
    let current = URL(fileURLWithPath: "/tmp/current.mp3")
    let other = URL(fileURLWithPath: "/tmp/other.mp3")

    #expect(AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: current,
        deletedURLs: [current]
    ))
    #expect(!AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: current,
        deletedURLs: [other]
    ))
    #expect(!AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: nil,
        deletedURLs: [current]
    ))
}
