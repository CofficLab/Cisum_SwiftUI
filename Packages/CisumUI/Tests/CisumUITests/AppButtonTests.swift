import Testing
@testable import LumiUI

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
}
