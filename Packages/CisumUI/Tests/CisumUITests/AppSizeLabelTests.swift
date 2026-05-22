import Foundation
import Testing
@testable import LumiUI

struct AppSizeLabelTests {
    @Test
    @MainActor
    func helperMatchesViewFormatting() {
        let label = AppSizeLabel(bytes: 1_536_000, style: .file)
        let expected = ByteCountFormatter.format(1_536_000, style: .file)

        #expect(label.formattedSize == expected)
    }
}
