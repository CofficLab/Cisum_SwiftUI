import Foundation
import Testing
@testable import PluginAudioControlButtons

@Test func navigationOnlyAppliesToTheRequestedCurrentAsset() {
    let requested = URL(fileURLWithPath: "/tmp/requested.mp3")
    let switched = URL(fileURLWithPath: "/tmp/switched.mp3")

    #expect(ControlButtonsPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true
    ))
    #expect(!ControlButtonsPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched,
        isSceneActive: true
    ))
    #expect(!ControlButtonsPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: false
    ))
}

@Test func deletionMatchesTheCurrentAssetButNotAnotherAsset() {
    let current = URL(fileURLWithPath: "/tmp/current.mp3")
    let other = URL(fileURLWithPath: "/tmp/other.mp3")

    #expect(ControlButtonsPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: current,
        deletedURLs: [current]
    ))
    #expect(!ControlButtonsPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: current,
        deletedURLs: [other]
    ))
}

@Test func deactivationInvalidatesPendingRequests() {
    let generation = ControlButtonsPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(generation == 3)
    #expect(!ControlButtonsPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: URL(fileURLWithPath: "/tmp/requested.mp3"),
        currentAsset: URL(fileURLWithPath: "/tmp/requested.mp3"),
        isSceneActive: true,
        currentGeneration: generation,
        requestGeneration: 2
    ))
}
