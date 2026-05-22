import Testing
@testable import LumiUI

struct AppIconButtonTests {
    @Test
    @MainActor
    func iconButtonPaddingTracksSize() {
        let compact = AppIconButton(systemImage: "bolt", size: .compact, action: {})
        let regular = AppIconButton(systemImage: "bolt", size: .regular, action: {})

        #expect(compact.resolvedContentPadding == 6)
        #expect(regular.resolvedContentPadding == 8)
    }
}
