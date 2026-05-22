import SwiftUI
import Testing
@testable import LumiUI

struct AppDualSegmentBarTests {
    @Test
    @MainActor
    func clampsRatioIntoZeroToOneRange() {
        let low = AppDualSegmentBar(leadingRatio: -1, leadingColor: .red, trailingColor: .blue)
        let high = AppDualSegmentBar(leadingRatio: 2, leadingColor: .red, trailingColor: .blue)

        #expect(low.leadingRatio == 0)
        #expect(high.leadingRatio == 1)
    }
}
