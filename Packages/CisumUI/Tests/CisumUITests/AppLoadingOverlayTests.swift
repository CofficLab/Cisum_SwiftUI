import Testing
@testable import LumiUI

struct AppLoadingOverlayTests {
    @Test
    @MainActor
    func loadingOverlayMapsSizesToExpectedScale() {
        #expect(AppLoadingOverlay(size: .small).scaleEffect == 0.8)
        #expect(AppLoadingOverlay(size: .medium).scaleEffect == 1.0)
        #expect(AppLoadingOverlay(size: .large).scaleEffect == 1.5)
    }
}
