import Foundation
import Testing
@testable import PluginSettingsButton

@Test func pluginMetadataIsStable() {
    #expect(SettingsButtonPluginInfo.toolbarItemId == "settings-button")
    #expect(SettingsButtonPluginInfo.settingsWindowID == "cisum.settings")
    #expect(SettingsButtonPluginInfo.iconName == "gearshape")
    #expect(!SettingsButtonPluginInfo.description.isEmpty)
    #expect(SettingsButtonView.title == "Settings")
}

@Test func pluginMetadataDescribesSettingsEntry() {
    #expect(SettingsButtonPlugin.metadata.displayName == "Settings")
    #expect(SettingsButtonPlugin.metadata.category == .settings)
    #expect(SettingsButtonPlugin.metadata.policy == .alwaysOn)
}
