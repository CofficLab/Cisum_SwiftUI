import Testing
@testable import CisumUI

struct AppTabBarTests {
    @Test
    func tabButtonAccessibilityLabelIncludesSelectionState() {
        #expect(AppTabBarAccessibilityPolicy.buttonLabel(title: "Search", isSelected: false) == "Search")
        #expect(AppTabBarAccessibilityPolicy.buttonLabel(title: "Search", isSelected: true) == "Search, selected")
    }
}
