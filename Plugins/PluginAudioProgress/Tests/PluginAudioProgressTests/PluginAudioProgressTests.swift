import Foundation
import Testing
@testable import PluginAudioProgress

@Test func audioProgressInfoExportsMetadata() {
    #expect(AudioProgressPluginInfo.titleKey == "Audio Progress")
    #expect(AudioProgressPluginInfo.table == "Audio-Progress")
}

@Test func leavingAudioScenePersistsProgress() {
    #expect(AudioProgressPersistencePolicy.shouldPersistWhenSceneChanges(
        from: "audio",
        to: "book",
        audioSceneName: "audio"
    ))
}

@Test func enteringAudioSceneDoesNotPersistStaleProgress() {
    #expect(!AudioProgressPersistencePolicy.shouldPersistWhenSceneChanges(
        from: "book",
        to: "audio",
        audioSceneName: "audio"
    ))
}

@Test func stayingInAudioSceneDoesNotDuplicateProgressSave() {
    #expect(!AudioProgressPersistencePolicy.shouldPersistWhenSceneChanges(
        from: "audio",
        to: "audio",
        audioSceneName: "audio"
    ))
}

@Test func clearingCurrentAudioURLPersistsNilCurrentAudio() {
    #expect(AudioProgressPersistencePolicy.currentURLToStore(nil) == nil)
}

@Test func emptyCloudAudioURLIsIgnored() {
    #expect(AudioStateRepo.storedURL(from: "") == nil)
    #expect(AudioStateRepo.storedURL(from: nil) == nil)
    #expect(AudioStateRepo.storedURL(from: "file:///tmp/audio/track.mp3") == URL(fileURLWithPath: "/tmp/audio/track.mp3"))
}

@Test func differentCurrentAudioURLResetsGlobalRestoreTime() {
    let oldURL = URL(fileURLWithPath: "/tmp/audio/track-01.mp3")
    let newURL = URL(fileURLWithPath: "/tmp/audio/track-02.mp3")

    #expect(AudioProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: oldURL, to: newURL))
    #expect(AudioProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: oldURL, to: nil))
    #expect(!AudioProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: oldURL, to: oldURL))
}

@Test func invalidRestoredAudioURLShouldClearCurrentAudio() {
    let url = URL(fileURLWithPath: "/tmp/audio/missing.mp3")

    #expect(AudioProgressPersistencePolicy.shouldClearRestoredCurrentURL(storedURL: url, isPlayable: false))
    #expect(!AudioProgressPersistencePolicy.shouldClearRestoredCurrentURL(storedURL: url, isPlayable: true))
    #expect(!AudioProgressPersistencePolicy.shouldClearRestoredCurrentURL(storedURL: nil, isPlayable: false))
}

@Test func restoreResultOnlyAppliesWhenCurrentAudioDidNotChange() {
    let starting = URL(fileURLWithPath: "/tmp/audio/track-01.mp3")
    let switched = URL(fileURLWithPath: "/tmp/audio/track-02.mp3")

    #expect(AudioProgressPersistencePolicy.shouldApplyRestoreResult(
        startingAsset: nil,
        currentAsset: nil
    ))
    #expect(AudioProgressPersistencePolicy.shouldApplyRestoreResult(
        startingAsset: starting,
        currentAsset: starting
    ))
    #expect(!AudioProgressPersistencePolicy.shouldApplyRestoreResult(
        startingAsset: nil,
        currentAsset: switched
    ))
    #expect(!AudioProgressPersistencePolicy.shouldApplyRestoreResult(
        startingAsset: starting,
        currentAsset: switched
    ))
}

@Test func widgetMetadataResultOnlyAppliesToStillCurrentAudio() {
    let requested = URL(fileURLWithPath: "/tmp/audio/track-01.mp3")
    let switched = URL(fileURLWithPath: "/tmp/audio/track-02.mp3")

    #expect(AudioProgressPersistencePolicy.shouldApplyWidgetMetadataResult(
        requestedAsset: requested,
        currentAsset: requested
    ))
    #expect(!AudioProgressPersistencePolicy.shouldApplyWidgetMetadataResult(
        requestedAsset: requested,
        currentAsset: switched
    ))
    #expect(!AudioProgressPersistencePolicy.shouldApplyWidgetMetadataResult(
        requestedAsset: requested,
        currentAsset: nil
    ))
}
