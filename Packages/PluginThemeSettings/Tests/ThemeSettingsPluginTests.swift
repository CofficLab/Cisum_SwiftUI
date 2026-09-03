import PluginThemeSettings
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(ThemeSettingsPluginInfo.iconName == "paintbrush")
    #expect(ThemeSettingsPluginInfo.order == 140)
}
