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
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-control-delete-tests", isDirectory: true)
    let current = root.appendingPathComponent("current.mp3")
    let unstandardizedCurrent = root
        .appendingPathComponent("nested", isDirectory: true)
        .appendingPathComponent("..", isDirectory: true)
        .appendingPathComponent("current.mp3")
    let other = root.appendingPathComponent("other.mp3")

    #expect(AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: current,
        deletedURLs: [current]
    ))
    #expect(AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: current,
        deletedURLs: [unstandardizedCurrent]
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

@Test func staleDeletionRecoveryDoesNotApplyAfterPlaybackSwitches() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-control-delete-tests", isDirectory: true)
    let deleted = root.appendingPathComponent("deleted.mp3")
    let switched = root.appendingPathComponent("switched.mp3")

    #expect(AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
        currentAsset: deleted,
        deletedURLs: [deleted]
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
        currentAsset: switched,
        deletedURLs: [deleted]
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
        currentAsset: nil,
        deletedURLs: [deleted]
    ))
}
