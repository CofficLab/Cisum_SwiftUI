import AVFoundation
import Combine
@testable import MagicPlayMan
import XCTest

final class MagicPlayManTests: XCTestCase {
    func testPlaybackEndNotificationMustBelongToCurrentItem() {
        let current = AVPlayerItem(url: URL(fileURLWithPath: "/tmp/current.mp3"))
        let stale = AVPlayerItem(url: URL(fileURLWithPath: "/tmp/stale.mp3"))

        XCTAssertTrue(MagicPlayMan.isPlaybackNotificationForCurrentItem(current, currentItem: current))
        XCTAssertFalse(MagicPlayMan.isPlaybackNotificationForCurrentItem(stale, currentItem: current))
        XCTAssertFalse(MagicPlayMan.isPlaybackNotificationForCurrentItem(nil, currentItem: current))
        XCTAssertFalse(MagicPlayMan.isPlaybackNotificationForCurrentItem(current, currentItem: nil))
        XCTAssertTrue(MagicPlayMan.isPlaybackEndNotificationForCurrentItem(current, currentItem: current))
        XCTAssertFalse(MagicPlayMan.isPlaybackEndNotificationForCurrentItem(stale, currentItem: current))
        XCTAssertFalse(MagicPlayMan.isPlaybackEndNotificationForCurrentItem(nil, currentItem: current))
        XCTAssertFalse(MagicPlayMan.isPlaybackEndNotificationForCurrentItem(current, currentItem: nil))
    }

    func testNowPlayingMetadataResultMustBelongToCurrentAsset() {
        let current = URL(fileURLWithPath: "/tmp/current.mp3")
        let stale = URL(fileURLWithPath: "/tmp/stale.mp3")

        XCTAssertTrue(MagicPlayMan.shouldApplyNowPlayingMetadataResult(requestedAsset: current, currentAsset: current))
        XCTAssertFalse(MagicPlayMan.shouldApplyNowPlayingMetadataResult(requestedAsset: stale, currentAsset: current))
        XCTAssertFalse(MagicPlayMan.shouldApplyNowPlayingMetadataResult(requestedAsset: current, currentAsset: nil))
    }

    func testAudioArtworkResultMustBelongToCurrentAsset() {
        let current = URL(fileURLWithPath: "/tmp/current.mp3")
        let stale = URL(fileURLWithPath: "/tmp/stale.mp3")

        XCTAssertTrue(AudioContentArtworkLoadPolicy.shouldApplyResult(requestedAsset: current, currentAsset: current))
        XCTAssertFalse(AudioContentArtworkLoadPolicy.shouldApplyResult(requestedAsset: stale, currentAsset: current))
    }

    func testRemoteCommandRegistrationReplacesExistingTargets() {
        XCTAssertFalse(MagicPlayMan.shouldReplaceRemoteCommandTargets(existingManagerCount: 0))
        XCTAssertTrue(MagicPlayMan.shouldReplaceRemoteCommandTargets(existingManagerCount: 1))
        XCTAssertTrue(MagicPlayMan.shouldReplaceRemoteCommandTargets(existingManagerCount: 3))
    }

    func testNowPlayingMetadataMatchesSymlinkedCurrentAsset() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realAsset = realFolder.appendingPathComponent("track.mp3")
        let linkedAsset = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realAsset)

        XCTAssertTrue(MagicPlayMan.shouldApplyNowPlayingMetadataResult(
            requestedAsset: linkedAsset,
            currentAsset: realAsset
        ))
        XCTAssertTrue(AudioContentArtworkLoadPolicy.shouldApplyResult(
            requestedAsset: linkedAsset,
            currentAsset: realAsset
        ))
    }

    func testDownloadResultMustBelongToCurrentAsset() {
        let current = URL(fileURLWithPath: "/tmp/current.mp3")
        let stale = URL(fileURLWithPath: "/tmp/stale.mp3")

        XCTAssertTrue(MagicPlayManDownloadRequestPolicy.shouldApplyResult(
            requestedAsset: current,
            currentAsset: current
        ))
        XCTAssertFalse(MagicPlayManDownloadRequestPolicy.shouldApplyResult(
            requestedAsset: stale,
            currentAsset: current
        ))
        XCTAssertFalse(MagicPlayManDownloadRequestPolicy.shouldApplyResult(
            requestedAsset: current,
            currentAsset: nil
        ))
        XCTAssertTrue(MagicPlayManDownloadRequestPolicy.shouldFinishDownload(
            requestedAsset: current,
            currentAsset: current
        ))
        XCTAssertFalse(MagicPlayManDownloadRequestPolicy.shouldFinishDownload(
            requestedAsset: stale,
            currentAsset: current
        ))
        XCTAssertFalse(MagicPlayManDownloadRequestPolicy.shouldFinishDownload(
            requestedAsset: current,
            currentAsset: nil
        ))
    }

    func testDownloadResultMatchesSymlinkedCurrentAsset() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realAsset = realFolder.appendingPathComponent("track.mp3")
        let linkedAsset = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realAsset)

        XCTAssertTrue(MagicPlayManDownloadRequestPolicy.shouldApplyResult(
            requestedAsset: linkedAsset,
            currentAsset: realAsset
        ))
        XCTAssertTrue(MagicPlayManDownloadRequestPolicy.shouldFinishDownload(
            requestedAsset: linkedAsset,
            currentAsset: realAsset
        ))
    }

    func testDownloadObserverCleanupOnlyUsesMatchingRequest() throws {
        let requested = URL(fileURLWithPath: "/tmp/requested.mp3")
        let other = URL(fileURLWithPath: "/tmp/other.mp3")

        XCTAssertTrue(MagicPlayManDownloadObserverPolicy.shouldUseObserver(
            requestedAsset: requested,
            observedAsset: requested
        ))
        XCTAssertFalse(MagicPlayManDownloadObserverPolicy.shouldUseObserver(
            requestedAsset: requested,
            observedAsset: other
        ))
        XCTAssertFalse(MagicPlayManDownloadObserverPolicy.shouldUseObserver(
            requestedAsset: requested,
            observedAsset: nil
        ))
    }

    func testDownloadObserverCleanupMatchesSymlinkedRequest() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realAsset = realFolder.appendingPathComponent("track.mp3")
        let linkedAsset = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realAsset)

        XCTAssertTrue(MagicPlayManDownloadObserverPolicy.shouldUseObserver(
            requestedAsset: linkedAsset,
            observedAsset: realAsset
        ))
    }

    @MainActor
    func testReplacingDownloadObserversCancelsPreviousObservers() {
        let man = MagicPlayMan()
        let previousCancellations = CancellationCounter()
        let nextCancellations = CancellationCounter()

        man.setCurrentDownloadObservers((
            asset: URL(fileURLWithPath: "/tmp/previous.mp3"),
            progressObserver: AnyCancellable { previousCancellations.increment() },
            finishObserver: AnyCancellable { previousCancellations.increment() }
        ))

        man.setCurrentDownloadObservers((
            asset: URL(fileURLWithPath: "/tmp/next.mp3"),
            progressObserver: AnyCancellable { nextCancellations.increment() },
            finishObserver: AnyCancellable { nextCancellations.increment() }
        ))

        XCTAssertEqual(previousCancellations.value, 2)
        XCTAssertEqual(nextCancellations.value, 0)
        XCTAssertEqual(man.currentDownloadObservers?.asset, URL(fileURLWithPath: "/tmp/next.mp3"))
    }

    @MainActor
    func testResetClearsDownloadObservers() async {
        let man = MagicPlayMan()
        let cancellations = CancellationCounter()

        man.setCurrentDownloadObservers((
            asset: URL(fileURLWithPath: "/tmp/current.mp3"),
            progressObserver: AnyCancellable { cancellations.increment() },
            finishObserver: AnyCancellable { cancellations.increment() }
        ))

        await man.reset(reason: "test")

        XCTAssertNil(man.currentDownloadObservers)
        XCTAssertEqual(cancellations.value, 2)
    }

    func testRemoteAssetsStillRequireExactURLIdentity() throws {
        let first = try XCTUnwrap(URL(string: "https://example.com/audio/track.mp3"))
        let second = try XCTUnwrap(URL(string: "https://cdn.example.com/audio/track.mp3"))

        XCTAssertTrue(MagicPlayManDownloadRequestPolicy.shouldApplyResult(
            requestedAsset: first,
            currentAsset: first
        ))
        XCTAssertFalse(MagicPlayManDownloadRequestPolicy.shouldApplyResult(
            requestedAsset: first,
            currentAsset: second
        ))
    }

    func testAssetCacheSeparatesDifferentURLsWithSameFilename() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let cache = try AssetCache(directory: root)
        let first = try XCTUnwrap(URL(string: "https://example.com/albums/one/track.mp3"))
        let second = try XCTUnwrap(URL(string: "https://cdn.example.net/library/two/track.mp3"))

        try cache.cache(Data("first".utf8), for: first)
        try cache.cache(Data("second".utf8), for: second)

        let firstCachedURL = try XCTUnwrap(cache.cachedURL(for: first))
        let secondCachedURL = try XCTUnwrap(cache.cachedURL(for: second))

        XCTAssertNotEqual(firstCachedURL, secondCachedURL)
        XCTAssertEqual(try Data(contentsOf: firstCachedURL), Data("first".utf8))
        XCTAssertEqual(try Data(contentsOf: secondCachedURL), Data("second".utf8))
    }

    func testAssetCacheHandlesLongSignedURLs() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let cache = try AssetCache(directory: root)
        let token = String(repeating: "abcdef0123456789", count: 40)
        let url = try XCTUnwrap(URL(string: "https://cdn.example.com/audio/track.mp3?signature=\(token)"))

        try cache.cache(Data("audio".utf8), for: url)
        let cachedURL = try XCTUnwrap(cache.cachedURL(for: url))

        XCTAssertLessThan(cachedURL.lastPathComponent.count, 100)
        XCTAssertEqual(cachedURL.pathExtension, "mp3")
        XCTAssertEqual(try Data(contentsOf: cachedURL), Data("audio".utf8))
    }

    func testAssetCacheReportsCachedDataSize() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let cache = try AssetCache(directory: root)
        let first = try XCTUnwrap(URL(string: "https://example.com/audio/first.mp3"))
        let second = try XCTUnwrap(URL(string: "https://example.com/audio/second.mp3"))

        try cache.cache(Data(repeating: 1, count: 12), for: first)
        try cache.cache(Data(repeating: 2, count: 8), for: second)

        XCTAssertEqual(try cache.size(), 20)
    }

    func testAssetCacheFileSizePolicyReadsFoundationNumberAttributes() {
        XCTAssertEqual(AssetCacheFileSizePolicy.fileSize(from: [.size: NSNumber(value: 1234)]), 1234)
        XCTAssertEqual(AssetCacheFileSizePolicy.fileSize(from: [.size: Int64(5678)]), 5678)
        XCTAssertEqual(AssetCacheFileSizePolicy.fileSize(from: [.size: Int(90)]), 90)
        XCTAssertEqual(AssetCacheFileSizePolicy.fileSize(from: [.size: UInt64(42)]), 42)
    }

    func testAssetCacheFileSizePolicyNormalizesInvalidSizes() {
        XCTAssertEqual(AssetCacheFileSizePolicy.fileSize(from: [.size: NSNumber(value: -1234)]), 0)
        XCTAssertEqual(AssetCacheFileSizePolicy.fileSize(from: [:]), 0)
    }

    func testAssetCacheReplacesFileAtCacheDirectory() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try Data("not a directory".utf8).write(to: root)

        let cache = try AssetCache(directory: root)
        let url = try XCTUnwrap(URL(string: "https://cdn.example.com/audio/track.mp3"))
        try cache.cache(Data("audio".utf8), for: url)

        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertNotNil(cache.cachedURL(for: url))
    }

    func testAssetCacheReplacesDanglingSymlinkAtCacheDirectory() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let cacheDirectory = root.appendingPathComponent("cache", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            at: cacheDirectory,
            withDestinationURL: root.appendingPathComponent("missing", isDirectory: true)
        )

        let cache = try AssetCache(directory: cacheDirectory)
        let url = try XCTUnwrap(URL(string: "https://cdn.example.com/audio/track.mp3"))
        try cache.cache(Data("audio".utf8), for: url)

        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: cacheDirectory.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertNotNil(cache.cachedURL(for: url))
    }

    @MainActor
    func testDefaultPlayerHasLocalization() {
        let man = MagicPlayMan()

        XCTAssertEqual(man.localization.noMediaSelected, "未选择媒体")
    }

    func testPlaybackRequestValidationRejectsMissingLocalFiles() {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp3")

        XCTAssertEqual(
            MagicPlayManPlaybackRequestPolicy.basicValidationError(for: missing),
            .invalidAsset
        )
    }

    func testPlaybackRequestValidationRejectsUnsupportedFiles() throws {
        let unsupported = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("txt")
        defer {
            try? FileManager.default.removeItem(at: unsupported)
        }

        try Data("not media".utf8).write(to: unsupported)

        XCTAssertEqual(
            MagicPlayManPlaybackRequestPolicy.basicValidationError(for: unsupported),
            .unsupportedFormat("txt")
        )
    }

    func testPlaybackRequestValidationAcceptsHLSStreams() {
        XCTAssertNil(MagicPlayManPlaybackRequestPolicy.basicValidationError(for: .sample_web_stream_basic))
        XCTAssertTrue(URL.sample_web_stream_basic.isVideo)
    }

    func testPlaybackRequestValidationAcceptsAudiobookFiles() throws {
        let audiobook = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4b")
        defer {
            try? FileManager.default.removeItem(at: audiobook)
        }

        try Data("audiobook".utf8).write(to: audiobook)

        XCTAssertNil(MagicPlayManPlaybackRequestPolicy.basicValidationError(for: audiobook))
        XCTAssertTrue(audiobook.isAudio)
    }

    @MainActor
    func testNewPlayRequestInvalidatesEarlierRequest() {
        let man = MagicPlayMan()

        let firstRequest = man.beginPlayRequest()
        let secondRequest = man.beginPlayRequest()

        XCTAssertFalse(man.isCurrentPlayRequest(firstRequest))
        XCTAssertTrue(man.isCurrentPlayRequest(secondRequest))
    }

    @MainActor
    func testResetInvalidatesPendingPlayRequest() async {
        let man = MagicPlayMan()
        let request = man.beginPlayRequest()

        await man.reset(reason: "test")

        XCTAssertFalse(man.isCurrentPlayRequest(request))
    }

    @MainActor
    func testStopInvalidatesPendingPlayRequest() async {
        let man = MagicPlayMan()
        let request = man.beginPlayRequest()

        await man.stop(reason: "test")

        XCTAssertFalse(man.isCurrentPlayRequest(request))
    }

    func testSeekPolicyClampsInvalidAndOutOfRangeTimes() {
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedTime(-5, duration: 100), 0)
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedTime(120, duration: 100), 100)
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedTime(40, duration: 100), 40)
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedTime(.infinity, duration: 100), 0)
    }

    func testSeekPolicyAllowsPositiveTimeWhenDurationIsUnknown() {
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedTime(30, duration: 0), 30)
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedTime(30, duration: .nan), 30)
    }

    func testSeekPolicyNormalizesOptionalStartTime() {
        XCTAssertNil(MagicPlayManSeekPolicy.normalizedStartTime(nil, duration: 100))
        XCTAssertNil(MagicPlayManSeekPolicy.normalizedStartTime(-5, duration: 100))
        XCTAssertNil(MagicPlayManSeekPolicy.normalizedStartTime(.nan, duration: 100))
        XCTAssertNil(MagicPlayManSeekPolicy.normalizedStartTime(.infinity, duration: 100))
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedStartTime(120, duration: 100), 100)
        XCTAssertEqual(MagicPlayManSeekPolicy.normalizedStartTime(30, duration: 0), 30)
    }

    func testControlInputPolicyNormalizesVolume() {
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedVolume(-0.25), 0)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedVolume(0.4), 0.4)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedVolume(1.5), 1)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedVolume(.nan), 0)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedVolume(.infinity), 0)
    }

    func testControlInputPolicyNormalizesSkipIntervals() {
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedSkipInterval(-5), 0)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedSkipInterval(15), 15)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedSkipInterval(.nan), 0)
        XCTAssertEqual(MagicPlayManControlInputPolicy.normalizedSkipInterval(.infinity), 0)
    }

    func testPlaybackTimePolicyRejectsInvalidTimes() {
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedCurrentTime(.nan), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedCurrentTime(.infinity), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedCurrentTime(-5), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedCurrentTime(42), 42)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedCurrentTime(120, duration: 100), 100)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedCurrentTime(120, duration: 0), 120)
    }

    func testPlaybackTimePolicyRejectsInvalidDurations() {
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedDuration(.nan), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedDuration(.infinity), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedDuration(-5), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedDuration(42), 42)
    }

    @MainActor
    func testDurationChangedNotificationPayloadIsNormalized() {
        let man = MagicPlayMan()
        var durations: [TimeInterval] = []
        let observer = NotificationCenter.default.addObserver(
            forName: .playManDurationChanged,
            object: man,
            queue: nil
        ) { notification in
            durations.append(notification.userInfo?["duration"] as? TimeInterval ?? -1)
        }
        defer {
            NotificationCenter.default.removeObserver(observer)
        }

        man.sendDurationChanged(duration: .nan)
        man.sendDurationChanged(duration: .infinity)
        man.sendDurationChanged(duration: -5)
        man.sendDurationChanged(duration: 42)

        XCTAssertEqual(durations, [0, 0, 0, 42])
    }

    func testPlaybackTimePolicyClampsProgress() {
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedUnitProgress(1.4), 1)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedUnitProgress(-0.2), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedUnitProgress(.nan), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedProgress(currentTime: 50, duration: 100), 0.5)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedProgress(currentTime: 120, duration: 100), 1)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedProgress(currentTime: -10, duration: 100), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedProgress(currentTime: .nan, duration: 100), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedProgress(currentTime: 10, duration: 0), 0)
        XCTAssertEqual(MagicPlayManPlaybackTimePolicy.normalizedProgress(currentTime: 10, duration: .infinity), 0)
    }

    func testPlaybackDownloadProgressTextIsClamped() {
        XCTAssertEqual(PlaybackState.downloadPercentText(for: .nan), "0%")
        XCTAssertEqual(PlaybackState.downloadPercentText(for: -.infinity), "0%")
        XCTAssertEqual(PlaybackState.downloadPercentText(for: -0.25), "0%")
        XCTAssertEqual(PlaybackState.downloadPercentText(for: 0.4), "40%")
        XCTAssertEqual(PlaybackState.downloadPercentText(for: 1.4), "100%")
        XCTAssertEqual(PlaybackState.loading(.downloading(1.4)).stateText, "Downloading... 100%")
    }

    func testTimeUpdatePolicyNormalizesInvalidPayloadValues() {
        let payload = MagicPlayManTimeUpdatePolicy.normalizedPayload(from: [
            "currentTime": TimeInterval.nan,
            "progress": Double.infinity,
        ])

        XCTAssertEqual(payload?.0, 0)
        XCTAssertEqual(payload?.1, 0)

        let clampedPayload = MagicPlayManTimeUpdatePolicy.normalizedPayload(from: [
            "currentTime": TimeInterval(-4),
            "progress": 1.4,
        ])

        XCTAssertEqual(clampedPayload?.0, 0)
        XCTAssertEqual(clampedPayload?.1, 1)
        XCTAssertNil(MagicPlayManTimeUpdatePolicy.normalizedPayload(from: ["currentTime": TimeInterval(12)]))
    }

    @MainActor
    func testTimeUpdateNotificationPayloadIsNormalized() {
        let man = MagicPlayMan()
        var payloads: [(TimeInterval, Double)] = []
        let observer = NotificationCenter.default.addObserver(
            forName: .playManTimeUpdate,
            object: man,
            queue: nil
        ) { notification in
            let currentTime = notification.userInfo?["currentTime"] as? TimeInterval ?? -1
            let progress = notification.userInfo?["progress"] as? Double ?? -1
            payloads.append((currentTime, progress))
        }
        defer {
            NotificationCenter.default.removeObserver(observer)
        }

        man.sendTimeUpdate(currentTime: .nan, progress: .infinity)
        man.sendTimeUpdate(currentTime: -4, progress: 1.4)
        man.sendTimeUpdate(currentTime: 12, progress: 0.25)

        XCTAssertEqual(payloads.map(\.0), [0, 0, 12])
        XCTAssertEqual(payloads.map(\.1), [0, 1, 0.25])
    }

    func testPlaybackTimePolicyRestartsWhenAtOrPastEnd() {
        XCTAssertTrue(MagicPlayManPlaybackTimePolicy.shouldRestartFromBeginning(currentTime: 100, duration: 100))
        XCTAssertTrue(MagicPlayManPlaybackTimePolicy.shouldRestartFromBeginning(currentTime: 100.01, duration: 100))
        XCTAssertFalse(MagicPlayManPlaybackTimePolicy.shouldRestartFromBeginning(currentTime: 99.9, duration: 100))
        XCTAssertFalse(MagicPlayManPlaybackTimePolicy.shouldRestartFromBeginning(currentTime: 10, duration: 0))
        XCTAssertFalse(MagicPlayManPlaybackTimePolicy.shouldRestartFromBeginning(currentTime: .nan, duration: 100))
    }

    @MainActor
    func testSetCurrentTimeDoesNotPublishInvalidTimes() {
        let man = MagicPlayMan()

        man.setCurrentTime(.nan, reason: "test")
        XCTAssertEqual(man.currentTime, 0)

        man.setCurrentTime(-5, reason: "test")
        XCTAssertEqual(man.currentTime, 0)
    }

    @MainActor
    func testSetCurrentTimeClampsToKnownDuration() {
        let man = MagicPlayMan()

        man.setDuration(100)
        man.setCurrentTime(120, reason: "test")

        XCTAssertEqual(man.currentTime, 100)
    }

    @MainActor
    func testSetDurationRejectsInvalidValues() {
        let man = MagicPlayMan()

        man.setDuration(-10)
        XCTAssertEqual(man.duration, 0)

        man.setDuration(.infinity)
        XCTAssertEqual(man.duration, 0)

        man.setDuration(75)
        XCTAssertEqual(man.duration, 75)
    }

    @MainActor
    func testSetProgressClampsInvalidValues() {
        let man = MagicPlayMan()

        man.setProgress(1.4)
        XCTAssertEqual(man.progress, 1)

        man.setProgress(-0.2)
        XCTAssertEqual(man.progress, 0)

        man.setProgress(.nan)
        XCTAssertEqual(man.progress, 0)
    }

    @MainActor
    func testUnplayableLocalMediaDoesNotBecomeCurrentAsset() async throws {
        let unplayable = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp3")
        defer {
            try? FileManager.default.removeItem(at: unplayable)
        }

        try Data("not a playable mp3".utf8).write(to: unplayable)

        let man = MagicPlayMan()
        await man.play(unplayable, autoPlay: false, reason: "test")

        XCTAssertNil(man.currentURL)
        XCTAssertEqual(man.currentError, .invalidAsset)
    }

    @MainActor
    func testChangingCurrentURLDoesNotSeekLoadedPlayerItem() async throws {
        let audio = try Self.makeSilentWAV()
        defer {
            try? FileManager.default.removeItem(at: audio)
        }

        let man = MagicPlayMan()
        man.player.replaceCurrentItem(with: AVPlayerItem(url: audio))
        try await Self.seek(man.player, to: 0.5)

        man.setCurrentURL(URL(fileURLWithPath: "/tmp/new-track.mp3"))
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThan(man.player.currentTime().seconds, 0.3)
    }

    @MainActor
    func testRestoringPlayModeDoesNotNotifySubscribers() {
        let man = MagicPlayMan()
        var notifications = 0
        let subscriptionID = man.subscribe(
            name: "MagicPlayManTests",
            onPlayModeChanged: { _ in
                notifications += 1
            }
        )
        defer {
            man.unsubscribe(subscriptionID)
        }

        man.restorePlayMode(.shuffle)

        XCTAssertEqual(man.playMode, .shuffle)
        XCTAssertEqual(notifications, 0)
    }

    @MainActor
    func testLikedAssetsMatchSymlinkedCurrentAsset() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realAsset = realFolder.appendingPathComponent("track.mp3")
        let linkedAsset = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realAsset)

        let man = MagicPlayMan()
        man.setLikedAssets([realAsset])
        man.setCurrentURL(linkedAsset)

        XCTAssertTrue(man.isCurrentAssetLiked)
    }

    @MainActor
    func testLikedAssetsDoNotMatchDistinctDanglingSymlinkAssets() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let missingAsset = root.appendingPathComponent("missing.mp3")
        let firstLink = root.appendingPathComponent("first.mp3")
        let secondLink = root.appendingPathComponent("second.mp3")
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: firstLink, withDestinationURL: missingAsset)
        try FileManager.default.createSymbolicLink(at: secondLink, withDestinationURL: missingAsset)

        let man = MagicPlayMan()
        man.setLikedAssets([firstLink])
        man.setCurrentURL(secondLink)

        XCTAssertFalse(man.isCurrentAssetLiked)
    }

    @MainActor
    func testRemovingLikeClearsSymlinkedStoredAsset() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realAsset = realFolder.appendingPathComponent("track.mp3")
        let linkedAsset = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realAsset)

        let man = MagicPlayMan()
        man.setLikedAssets([realAsset])
        man.setCurrentURL(linkedAsset)
        man.setLike(false, reason: "test")

        XCTAssertFalse(man.isCurrentAssetLiked)
        XCTAssertTrue(man.likedAssets.isEmpty)
    }

    @MainActor
    func testAddingLikeReplacesSymlinkedStoredAsset() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realAsset = realFolder.appendingPathComponent("track.mp3")
        let linkedAsset = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realAsset)

        let man = MagicPlayMan()
        man.setLikedAssets([realAsset])
        man.setCurrentURL(linkedAsset)
        man.setLike(true, reason: "test")

        XCTAssertEqual(man.likedAssets.count, 1)
        XCTAssertTrue(man.likedAssets.contains(linkedAsset))
    }

    @MainActor
    func testFailedPlaybackStateNotifiesFailureSubscribers() async throws {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp3")
        let man = MagicPlayMan()
        var receivedError: PlaybackState.PlaybackError?
        let subscriptionID = man.subscribe(
            name: "MagicPlayManTests",
            onPlaybackFailed: { error in
                receivedError = error
            }
        )
        defer {
            man.unsubscribe(subscriptionID)
        }

        await man.play(missing, autoPlay: false, reason: "test")
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(receivedError, .invalidAsset)
    }

    @MainActor
    func testCurrentItemFailureNotificationFailsPlayback() async throws {
        let audio = try Self.makeSilentWAV()
        defer {
            try? FileManager.default.removeItem(at: audio)
        }

        let man = MagicPlayMan()
        let item = AVPlayerItem(url: audio)
        man.player.replaceCurrentItem(with: item)
        man.setCurrentURL(audio)
        man.setDuration(10)
        man.setCurrentTime(5, reason: "test")
        man.setProgress(0.5)
        let error = NSError(domain: "MagicPlayManTests", code: 99)

        man.handlePlaybackItemFailureNotification(Notification(
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            userInfo: [AVPlayerItemFailedToPlayToEndTimeErrorKey: error]
        ))

        XCTAssertNil(man.player.currentItem)
        XCTAssertNil(man.currentURL)
        XCTAssertEqual(man.currentTime, 0)
        XCTAssertEqual(man.duration, 0)
        XCTAssertEqual(man.progress, 0)
        XCTAssertEqual(man.currentError, .playbackError(error.localizedDescription))
    }

    @MainActor
    func testStaleItemFailureNotificationDoesNotFailCurrentPlayback() async throws {
        let currentAudio = try Self.makeSilentWAV()
        let staleAudio = try Self.makeSilentWAV()
        defer {
            try? FileManager.default.removeItem(at: currentAudio)
            try? FileManager.default.removeItem(at: staleAudio)
        }

        let man = MagicPlayMan()
        let currentItem = AVPlayerItem(url: currentAudio)
        let staleItem = AVPlayerItem(url: staleAudio)
        man.player.replaceCurrentItem(with: currentItem)

        man.handlePlaybackItemFailureNotification(Notification(
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: staleItem,
            userInfo: [AVPlayerItemFailedToPlayToEndTimeErrorKey: NSError(domain: "MagicPlayManTests", code: 100)]
        ))

        XCTAssertNil(man.currentError)
    }

    @MainActor
    func testStopSynchronizesPublishedPlaybackState() async throws {
        let audio = try Self.makeSilentWAV()
        defer {
            try? FileManager.default.removeItem(at: audio)
        }

        let man = MagicPlayMan()
        man.player.replaceCurrentItem(with: AVPlayerItem(url: audio))
        man.setCurrentURL(audio)
        man.setDuration(10)
        man.setCurrentTime(5, reason: "test")
        man.setProgress(0.5)
        man.setState(.playing, reason: "test")

        await man.stop(reason: "test")

        XCTAssertEqual(man.currentURL, audio)
        XCTAssertEqual(man.state, .stopped)
        XCTAssertEqual(man.currentTime, 0)
        XCTAssertEqual(man.progress, 0)
    }

    private static func makeSilentWAV() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        let file = try AVAudioFile(forWriting: url, settings: format.settings)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44_100)!
        buffer.frameLength = 44_100
        try file.write(from: buffer)
        return url
    }

    private static func seek(_ player: AVPlayer, to seconds: TimeInterval) async throws {
        try await withCheckedThrowingContinuation { continuation in
            player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600)) { finished in
                if finished {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: CancellationError())
                }
            }
        }
    }
}

private final class CancellationCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return count
    }

    func increment() {
        lock.lock()
        defer { lock.unlock() }
        count += 1
    }
}
