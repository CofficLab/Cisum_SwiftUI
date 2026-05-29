public enum AudioPluginInfo {
    public static let titleKey = "Music"
    public static let descriptionKey = "Audio playback"
    public static let table = "Audio"
    public static let maxAudioCount = 100
    public static let dbDirName = "audios"
    public static let debugDBDirName = "audios_debug"
    public static let supportedExtensions = [
        "mp3",
        "m4a",
        "flac",
        "wav",
    ]
}
