import Foundation
import Testing
@testable import MagicKit

@Test func relativeTimeFormatsPastAndFutureDates() {
    let now = Date(timeIntervalSince1970: 1_000_000)

    #expect(DateRelativeTimePolicy.relativeTime(for: now.addingTimeInterval(-30), now: now) == "刚刚")
    #expect(DateRelativeTimePolicy.relativeTime(for: now.addingTimeInterval(-300), now: now) == "5分钟前")
    #expect(DateRelativeTimePolicy.relativeTime(for: now.addingTimeInterval(-7200), now: now) == "2小时前")
    #expect(DateRelativeTimePolicy.relativeTime(for: now.addingTimeInterval(300), now: now) == "5分钟后")
}

@Test func relativeTimeNormalizesInvalidDates() {
    let invalid = Date(timeIntervalSince1970: .nan)

    #expect(DateRelativeTimePolicy.relativeTime(for: invalid) == "刚刚")
    #expect(DateRelativeTimePolicy.smartRelativeTime(for: invalid) == "刚刚")
}
