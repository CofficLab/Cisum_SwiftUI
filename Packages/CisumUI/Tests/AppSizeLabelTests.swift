import Foundation
import Testing
@testable import CisumUI

struct AppSizeLabelTests {
    @Test
    @MainActor
    func helperMatchesViewFormatting() {
        let label = AppSizeLabel(bytes: 1_536_000, style: .file)
        let expected = ByteCountFormatter.format(1_536_000, style: .file)

        #expect(label.formattedSize == expected)
    }

    @Test
    @MainActor
    func negativeByteCountsDisplayAsZero() {
        let label = AppSizeLabel(bytes: -1, style: .file)
        let expected = ByteCountFormatter.format(0, style: .file)

        #expect(label.bytes == 0)
        #expect(label.formattedSize == expected)
        #expect(ByteCountFormatter.format(-1, style: .file) == expected)
    }
}
