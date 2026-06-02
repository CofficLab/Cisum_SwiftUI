@testable import CisumUI
import Testing

@Test func copyMessageButtonUsesEnglishFeedbackText() {
    #expect(CopyMessageButton.copiedLabel == "Copied")
    #expect(CopyMessageButton.accessibilityLabel == "Copy message content")
    #expect(CopyMessageButton.helpText == "Copy message content")
}

@Test func copyMessageButtonUsesCopyHelpAsAccessibilityLabel() {
    #expect(CopyMessageButton.accessibilityLabel == CopyMessageButton.helpText)
}
