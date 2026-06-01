@testable import CisumUI
import Testing

@Test func copyMessageButtonUsesEnglishFeedbackText() {
    #expect(CopyMessageButton.copiedLabel == "Copied")
    #expect(CopyMessageButton.helpText == "Copy message content")
}
