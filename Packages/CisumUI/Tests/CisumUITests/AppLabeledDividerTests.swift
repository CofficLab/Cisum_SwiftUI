import Testing
@testable import LumiUI

struct AppLabeledDividerTests {
    @Test
    @MainActor
    func preservesOptionalDetail() {
        let dividerWithDetail = AppLabeledDivider(title: "End", detail: "12:34:56")
        let dividerWithoutDetail = AppLabeledDivider(title: "End")

        #expect(dividerWithDetail.detail == "12:34:56")
        #expect(dividerWithoutDetail.detail == nil)
    }
}
