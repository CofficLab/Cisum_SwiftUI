import Testing
@testable import CisumUI

struct AppIconButtonTests {
    @Test
    @MainActor
    func iconButtonPaddingTracksSize() {
        let compact = AppIconButton(systemImage: "bolt", size: .compact, action: {})
        let regular = AppIconButton(systemImage: "bolt", size: .regular, action: {})

        #expect(compact.resolvedContentPadding == 6)
        #expect(regular.resolvedContentPadding == 8)
    }

    @Test
    @MainActor
    func iconButtonAlwaysHasReadableAccessibilityLabel() {
        let labeled = AppIconButton(systemImage: "plus", label: "Add", action: {})
        let fallback = AppIconButton(systemImage: "gearshape", action: {})

        #expect(labeled.resolvedAccessibilityLabel == "Add")
        #expect(fallback.resolvedAccessibilityLabel == "gearshape")
    }
}
