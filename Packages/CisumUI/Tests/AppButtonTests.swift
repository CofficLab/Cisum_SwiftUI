import Testing
@testable import CisumUI

struct AppButtonTests {
    @Test
    @MainActor
    func smallButtonUsesCompactMetrics() {
        let button = AppButton("Run", size: .small, action: {})

        #expect(button.metrics.horizontalPadding == 10)
        #expect(button.metrics.verticalPadding == 6)
    }

    @Test
    @MainActor
    func mediumButtonUsesDefaultMetrics() {
        let button = AppButton("Run", size: .medium, action: {})

        #expect(button.metrics.horizontalPadding == 14)
        #expect(button.metrics.verticalPadding == 10)
    }

    @Test
    @MainActor
    func iconOnlyButtonRequiresExplicitAccessibilityLabel() {
        let button = AppButton(systemImage: "gearshape", accessibilityLabel: "Settings", action: {})

        #expect(button.hasExplicitAccessibilityLabel)
    }

    @Test
    @MainActor
    func iconOnlyButtonKeepsCompatibilityAccessibilityFallback() {
        let button = AppButton(systemImage: "gearshape", action: {})

        #expect(button.hasExplicitAccessibilityLabel)
    }
}
