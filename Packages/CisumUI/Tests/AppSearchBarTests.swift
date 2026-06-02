import Testing
@testable import CisumUI

struct AppSearchBarTests {
    @Test
    func clearButtonUsesReadableAccessibilityLabel() {
        #expect(AppSearchBar.clearSearchLabel == "Clear search")
    }
}
