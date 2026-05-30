@testable import PluginWelcome
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(WelcomePluginInfo.iconName == "hand.wave")
    #expect(WelcomePluginInfo.emoji == "👏")
    #expect(WelcomePluginInfo.order == -100)
}

@Test func storageSelectionDefaultsToICloudWhenAvailable() {
    #expect(WelcomeStorageSelectionPolicy.defaultSelection(
        currentStorageSelection: nil,
        isICloudAvailable: true
    ) == .icloud)
}

@Test func storageSelectionFallsBackToLocalWhenICloudUnavailable() {
    #expect(WelcomeStorageSelectionPolicy.defaultSelection(
        currentStorageSelection: .icloud,
        isICloudAvailable: false
    ) == .local)
    #expect(WelcomeStorageSelectionPolicy.validatedSelection(
        .icloud,
        isICloudAvailable: false
    ) == .local)
}
