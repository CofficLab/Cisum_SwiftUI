import Foundation

public enum AudioScenePluginInfo {
    public static let title = String(localized: "Music Scene", table: "Audio-Scene", bundle: .module)
    public static let description = String(localized: "Provides music library scene", table: "Audio-Scene", bundle: .module)
    public static let iconName = "music.note.list"
    public static let sceneName = "Music Library"
    public static let order = 0
}
