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
}
