import Testing
@testable import CisumUI

struct AppActivityIconButtonTests {
    @Test
    @MainActor
    func activityIconButtonUsesLabelForAccessibility() {
        let button = AppActivityIconButton(systemImage: "folder", label: "Projects", action: {})

        #expect(button.resolvedAccessibilityLabel == "Projects")
    }
}
