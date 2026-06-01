import Foundation

public enum AudioDownloadPluginInfo {
    public static let title = String(localized: "Audio Download", table: "Audio-Download", bundle: .module)
    public static let description = String(localized: "Auto download audio files", table: "Audio-Download", bundle: .module)
    public static let iconName = "icloud.and.arrow.down"
    public static let emoji = "⬇️"
    public static let order = 2
    public static let audioSceneName = "Music Library"
}
