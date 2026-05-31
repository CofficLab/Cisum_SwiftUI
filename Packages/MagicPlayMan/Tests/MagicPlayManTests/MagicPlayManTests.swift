import AVFoundation
@testable import MagicPlayMan
import XCTest

final class MagicPlayManTests: XCTestCase {
    func testPlaybackEndNotificationMustBelongToCurrentItem() {
        let current = AVPlayerItem(url: URL(fileURLWithPath: "/tmp/current.mp3"))
        let stale = AVPlayerItem(url: URL(fileURLWithPath: "/tmp/stale.mp3"))

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
}
