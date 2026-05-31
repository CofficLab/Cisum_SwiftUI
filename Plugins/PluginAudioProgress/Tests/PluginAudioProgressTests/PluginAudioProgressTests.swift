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
    let stored = URL(fileURLWithPath: "/tmp/audio/track.mp3")

    #expect(AudioProgressPersistencePolicy.currentURLToStore(
        nil,
        storedURL: stored,
        supportedExtensions: ["mp3"]
    ) == nil)
}

@Test func supportedCurrentAudioURLPersistsCurrentAudio() {
    let stored = URL(fileURLWithPath: "/tmp/audio/track-01.mp3")
    let current = URL(fileURLWithPath: "/tmp/audio/track-02.FLAC")

    #expect(AudioProgressPersistencePolicy.currentURLToStore(
        current,
        storedURL: stored,
        supportedExtensions: ["mp3", "flac"]
    ) == current)
}

@Test func unsupportedCurrentURLKeepsPreviousAudio() {
    let stored = URL(fileURLWithPath: "/tmp/audio/track.mp3")
    let video = URL(fileURLWithPath: "/tmp/video/movie.mp4")

    #expect(AudioProgressPersistencePolicy.currentURLToStore(
        video,
        storedURL: stored,
        supportedExtensions: ["mp3"]
    ) == stored)
}

@Test func emptyCloudAudioURLIsIgnored() {
    #expect(AudioStateRepo.storedURL(from: "") == nil)
    #expect(AudioStateRepo.storedURL(from: nil) == nil)
    #expect(AudioStateRepo.storedURL(from: "file:///tmp/audio/track.mp3") == URL(fileURLWithPath: "/tmp/audio/track.mp3"))
    #expect(AudioStateRepo.storedURL(from: "/tmp/audio/legacy-track.mp3") == URL(fileURLWithPath: "/tmp/audio/legacy-track.mp3"))
    #expect(AudioStateRepo.storedURL(from: "not a url") == nil)
}

@Test func localZeroAudioTimeOverridesStaleCloudTime() {
    #expect(AudioStateRepo.storedTime(
        localObject: 0.0,
        localDouble: 0,
        cloudString: "42"
    ) == 0)
    #expect(AudioStateRepo.storedTime(
        localObject: nil,
        localDouble: 0,
        cloudString: "42"
    ) == 42)
    #expect(AudioStateRepo.storedTime(
        localObject: nil,
        localDouble: 0,
        cloudString: "not a time"
    ) == nil)
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

@Test func restoreDoesNotReplayAlreadyLoadedAudio() {
    let restored = URL(fileURLWithPath: "/tmp/audio/track-01.mp3")
    let other = URL(fileURLWithPath: "/tmp/audio/track-02.mp3")

    #expect(!AudioProgressPersistencePolicy.shouldPlayRestoredAsset(
        restoredAsset: restored,
        currentAsset: restored
    ))
    #expect(AudioProgressPersistencePolicy.shouldPlayRestoredAsset(
        restoredAsset: restored,
        currentAsset: other
    ))
    #expect(AudioProgressPersistencePolicy.shouldPlayRestoredAsset(
        restoredAsset: restored,
        currentAsset: nil
    ))
}

@Test func staleCurrentAudioURLChangeDoesNotOverwriteNewTrack() {
    let requested = URL(fileURLWithPath: "/tmp/audio/track-01.mp3")
    let switched = URL(fileURLWithPath: "/tmp/audio/track-02.mp3")

    #expect(AudioProgressPersistencePolicy.shouldApplyCurrentURLChange(
        requestedURL: requested,
        currentAsset: requested
    ))
    #expect(!AudioProgressPersistencePolicy.shouldApplyCurrentURLChange(
        requestedURL: requested,
        currentAsset: switched
    ))
    #expect(!AudioProgressPersistencePolicy.shouldApplyCurrentURLChange(
        requestedURL: requested,
        currentAsset: nil
    ))
    #expect(AudioProgressPersistencePolicy.shouldApplyCurrentURLChange(
        requestedURL: nil,
        currentAsset: nil
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
