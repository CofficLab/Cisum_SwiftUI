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
        currentAsset: requested,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: nil,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: false
    ))
}

@Test func navigationResultAppliesToSymlinkedCurrentAsset() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: linkedFile,
        currentAsset: realFile,
        isSceneActive: true
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

@Test func deletionAffectsCurrentAssetThroughSymlink() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: realFile,
        deletedURLs: [linkedFile]
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

@Test func staleDeletionRecoveryDoesNotApplyAfterSceneReactivation() {
    let deleted = URL(fileURLWithPath: "/tmp/cisum-audio-control-delete-tests/deleted.mp3")
    let generation = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
        currentAsset: deleted,
        deletedURLs: [deleted],
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
        currentAsset: deleted,
        deletedURLs: [deleted],
        currentGeneration: generation,
        requestGeneration: 2
    ))
}

@Test func storageResetOnlyAppliesInActiveAudioScene() {
    #expect(AudioControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: true))
    #expect(!AudioControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: false))
}

@Test func staleAudioStorageResetDoesNotApplyAfterDeactivation() {
    let generation = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(generation == 3)
    #expect(AudioControlPlaybackRequestPolicy.shouldApplyStorageReset(
        currentGeneration: 2,
        requestGeneration: 2,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyStorageReset(
        currentGeneration: generation,
        requestGeneration: 2,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyStorageReset(
        currentGeneration: 2,
        requestGeneration: 2,
        isSceneActive: false
    ))
}

@Test func staleEmptyLibraryNavigationDoesNotResetSwitchedPlayback() {
    let requested = URL(fileURLWithPath: "/tmp/cisum-audio-control-empty/requested.mp3")
    let switched = URL(fileURLWithPath: "/tmp/cisum-audio-control-empty/switched.mp3")

    #expect(AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched,
        isSceneActive: true
    ))
}

@Test func staleNavigationDoesNotApplyAfterSceneReactivation() {
    let requested = URL(fileURLWithPath: "/tmp/cisum-audio-control-stale/requested.mp3")
    let generation = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true,
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true,
        currentGeneration: generation,
        requestGeneration: 2
    ))
}

@Test func staleNavigationFailureDoesNotReportAfterPlaybackSwitches() {
    let requested = URL(fileURLWithPath: "/tmp/cisum-audio-control-failure/requested.mp3")
    let switched = URL(fileURLWithPath: "/tmp/cisum-audio-control-failure/switched.mp3")

    #expect(AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
        requestedAsset: requested,
        currentAsset: switched,
        isSceneActive: true
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: false
    ))
}

@Test func staleNavigationFailureDoesNotReportAfterSceneReactivation() {
    let requested = URL(fileURLWithPath: "/tmp/cisum-audio-control-failure/requested.mp3")
    let generation = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true,
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true,
        currentGeneration: generation,
        requestGeneration: 2
    ))
}
