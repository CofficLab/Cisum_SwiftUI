import SwiftUI
import Testing
@testable import CisumUI

struct AppDualSegmentBarTests {
    @Test
    @MainActor
    func clampsRatioIntoZeroToOneRange() {
        let low = AppDualSegmentBar(leadingRatio: -1, leadingColor: .red, trailingColor: .blue)
        let high = AppDualSegmentBar(leadingRatio: 2, leadingColor: .red, trailingColor: .blue)

        #expect(low.leadingRatio == 0)
        #expect(high.leadingRatio == 1)
    }

    @Test
    @MainActor
    func normalizesNonFiniteRatioToZero() {
        let notANumber = AppDualSegmentBar(leadingRatio: .nan, leadingColor: .red, trailingColor: .blue)
        let infinite = AppDualSegmentBar(leadingRatio: .infinity, leadingColor: .red, trailingColor: .blue)

        #expect(notANumber.leadingRatio == 0)
        #expect(infinite.leadingRatio == 0)
    }

    @Test
    @MainActor
    func fallsBackForInvalidDimensions() {
        let invalid = AppDualSegmentBar(
            leadingRatio: 0.5,
            leadingColor: .red,
            trailingColor: .blue,
            width: .nan,
            height: -1
        )

        #expect(invalid.width == 120)
        #expect(invalid.height == 4)
    }
}
