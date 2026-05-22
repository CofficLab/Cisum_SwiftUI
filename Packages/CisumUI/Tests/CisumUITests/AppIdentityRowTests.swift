import Testing
@testable import LumiUI

struct AppIdentityRowTests {
    @Test
    @MainActor
    func filtersBlankMetadataEntries() {
        let row = AppIdentityRow(title: "Lumi", metadata: ["gpt-5.4", "", "  ", "openai"])

        #expect(row.metadata == ["gpt-5.4", "openai"])
    }
}
