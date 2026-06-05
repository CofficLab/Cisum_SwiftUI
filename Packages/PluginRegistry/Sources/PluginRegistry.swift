@_exported import CisumUI
@_exported import AudioPlugin
@_exported import AudioControlPlugin
@_exported import AudioCopyPlugin
@_exported import AudioDBViewPlugin
@_exported import AudioDemoPlugin
@_exported import AudioDownloadPlugin
@_exported import AudioJobPlugin
@_exported import AudioLikePlugin
@_exported import AudioPlayModePlugin
@_exported import AudioProgressPlugin
@_exported import AudioScenePlugin
@_exported import AudioSettingsPlugin
@_exported import AudioWidgetControlPlugin
@_exported import BookPlugin
@_exported import BookControlPlugin
@_exported import BookDBViewPlugin
@_exported import BookLikePlugin
@_exported import BookPlayModePlugin
@_exported import BookProgressPlugin
@_exported import BookScenePlugin
@_exported import BookSettingsPlugin
@_exported import FileLogPlugin
@_exported import LikeButtonPlugin
@_exported import OpenButtonPlugin
@_exported import ResetPlugin
@_exported import StoragePlugin
@_exported import StorePlugin
@_exported import ThemeAuroraPlugin
@_exported import ThemeCisumPlugin
@_exported import ThemeDaylightSilverPlugin
@_exported import ThemeForestPlugin
@_exported import ThemeGraphiteBlackPlugin
@_exported import ThemeMidnightPlugin
@_exported import ThemeMonoPlugin
@_exported import ThemeNebulaPlugin
@_exported import ThemeOceanPlugin
@_exported import ThemePaperPlugin
@_exported import ThemeSettingsPlugin
@_exported import ThemeStudioBluePlugin
@_exported import ThemeSunsetPlugin
@_exported import WelcomePlugin

/// Central plugin registry.
///
/// Manually maintained list of all plugins available to Cisum.
/// When adding a new plugin, update both the `Package.swift` dependencies
/// and the `plugins` array below.
///
/// ## Module Name → Plugin Type Mapping
///
/// Most modules use a matching plugin type name (e.g. `AudioPlugin` module → `AudioPlugin` type).
/// Notable exceptions:
///
/// | Module                | Plugin Type  |
/// |-----------------------|--------------|
/// | `AudioCopyPlugin`     | `CopyPlugin` |
/// | `AudioDBViewPlugin`   | `AudioDBPlugin` |
/// | `BookDBViewPlugin`    | `BookDBPlugin` |
/// | `ResetPlugin`         | `SystemPlugin` |
///
/// The `PluginRegistry/Package.swift` dependency list must stay in sync
/// with the `import` statements and `plugins.append(...)` calls below.
public enum PluginRegistry {
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
