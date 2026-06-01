import Testing
@testable import CisumUI

struct StatusBarHoverContainerTests {
    @Test
    func detailTriggerUsesAccessibleHint() {
        #expect(StatusBarHoverContainerAccessibilityPolicy.showDetailsHint == "Show details")
    }
}
