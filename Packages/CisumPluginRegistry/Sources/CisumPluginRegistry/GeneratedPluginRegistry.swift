import CisumUI
import PluginAudio
import PluginAudioControl
import PluginAudioCopy
import PluginAudioDBView
import PluginAudioDemo
import PluginAudioDownload
import PluginAudioJob
import PluginAudioLike
import PluginAudioPlayMode
import PluginAudioProgress
import PluginAudioScene
import PluginAudioSettings
import PluginAudioWidgetControl
import PluginBook
import PluginBookControl
import PluginBookDBView
import PluginBookLike
import PluginBookPlayMode
import PluginBookProgress
import PluginBookScene
import PluginBookSettings
import PluginFileLog
import PluginLikeButton
import PluginOpenButton
import PluginReset
import PluginStorage
import PluginStore
import PluginThemeAurora
import PluginThemeCisum
import PluginThemeDaylightSilver
import PluginThemeForest
import PluginThemeGraphiteBlack
import PluginThemeMidnight
import PluginThemeMono
import PluginThemeNebula
import PluginThemeOcean
import PluginThemePaper
import PluginThemeSettings
import PluginThemeStudioBlue
import PluginThemeSunset
import PluginWelcome

/// Central plugin registry.
///
/// Add packaged plugins here explicitly when they should be available to Cisum.
public enum GeneratedPluginRegistry {
    @MainActor
    public static var plugins: [any SuperPlugin] {
        var plugins: [any SuperPlugin] = []

        plugins.append(AudioControlPlugin.shared)
        plugins.append(AudioDBPlugin.shared)
        plugins.append(AudioDemoPlugin.shared)
        plugins.append(AudioDownloadPlugin.shared)
        plugins.append(AudioJobPlugin.shared)
        plugins.append(AudioLikePlugin.shared)
        plugins.append(AudioPlayModePlugin.shared)
        plugins.append(AudioPlugin.shared)
        plugins.append(AudioProgressPlugin.shared)
        plugins.append(AudioScenePlugin.shared)
        plugins.append(AudioSettingsPlugin.shared)
        plugins.append(AudioWidgetControlPlugin.shared)
        plugins.append(BookControlPlugin.shared)
        plugins.append(BookDBPlugin.shared)
        plugins.append(BookLikePlugin.shared)
        plugins.append(BookPlayModePlugin.shared)
        plugins.append(BookPlugin.shared)
        plugins.append(BookProgressPlugin.shared)
        plugins.append(BookScenePlugin.shared)
        plugins.append(BookSettingsPlugin.shared)
        #if os(macOS)
            plugins.append(CopyPlugin.shared)
            plugins.append(FileLogPlugin.shared)
        #endif
        plugins.append(LikeButtonPlugin.shared)
        plugins.append(OpenButtonPlugin.shared)
        plugins.append(StoragePlugin.shared)
        plugins.append(StorePlugin.shared)
        plugins.append(SystemPlugin.shared)
        plugins.append(ThemeAuroraPlugin.shared)
        plugins.append(ThemeCisumPlugin.shared)
        plugins.append(ThemeDaylightSilverPlugin.shared)
        plugins.append(ThemeForestPlugin.shared)
        plugins.append(ThemeGraphiteBlackPlugin.shared)
        plugins.append(ThemeMidnightPlugin.shared)
        plugins.append(ThemeMonoPlugin.shared)
        plugins.append(ThemeNebulaPlugin.shared)
        plugins.append(ThemeOceanPlugin.shared)
        plugins.append(ThemePaperPlugin.shared)
        plugins.append(ThemeSettingsPlugin.shared)
        plugins.append(ThemeStudioBluePlugin.shared)
        plugins.append(ThemeSunsetPlugin.shared)
        plugins.append(WelcomePlugin.shared)

        return plugins
    }
}
