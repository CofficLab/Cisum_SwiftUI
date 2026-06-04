import Foundation
import SwiftUI
import CisumUI

/// 本地化字符串管理
public struct Localization {
    private let bundle: Bundle
    private let locale: Locale

    public init(locale: Locale = .current) {
        self.bundle = .module
        self.locale = locale
    }

    /// 在 Localizable.xcstrings 中查找指定 locale 的翻译
    private func localized(_ key: String) -> String {
        guard let url = bundle.url(forResource: "Localizable", withExtension: "xcstrings"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else {
            return key
        }

        guard let entry = strings[key] as? [String: Any],
              let localizations = entry["localizations"] as? [String: Any] else {
            return key
        }

        let preferredLocales = [
            locale.identifier,
            "\(locale.languageCode ?? "en")-\(locale.regionCode ?? "")",
            locale.languageCode ?? "en",
            "zh-Hans",
            "en",
        ]

        for localeId in preferredLocales {
            if let loc = localizations[localeId] as? [String: Any],
               let stringUnit = loc["stringUnit"] as? [String: Any],
               let value = stringUnit["value"] as? String,
               !value.isEmpty {
                return value
            }
            // 也尝试带变体的 locale（如 zh-Hans-CN）
            if let loc = localizations[localeId.replacing("-", with: "_")] as? [String: Any],
               let stringUnit = loc["stringUnit"] as? [String: Any],
               let value = stringUnit["value"] as? String,
               !value.isEmpty {
                return value
            }
        }

        return key
    }

    // MARK: - Common
    public var retry: String { localized("Retry") }
    public var loadingWithDots: String { localized("Loading...") }
    public var error: String { localized("Error") }

    // MARK: - Audio Content
    public var noArtworkAvailable: String { localized("No artwork available") }
    public var failedToLoadArtwork: String { localized("Failed to load artwork") }

    // MARK: - Format Info
    public var supportedFormats: String { localized("Supported Formats") }

    // MARK: - Error / Loading
    public var failedToLoadMedia: String { localized("Failed to Load Media") }

    // MARK: - Thumbnail
    public var noArtwork: String { localized("No Artwork") }

    // MARK: - Subscribers
    public var eventSubscribers: String { localized("Event Subscribers") }
    public var noSubscribersRegistered: String { localized("No subscribers are currently registered.") }
    public var noSubscribers: String { localized("No Subscribers") }
    public var since: String { localized("Since") }

    // MARK: - Play Mode
    public var lightMode: String { localized("Light Mode") }
    public var darkMode: String { localized("Dark Mode") }

    // MARK: - Buttons
    public var differentSizes: String { localized("Different Sizes") }

    // MARK: - Playback State
    public var nowPlaying: String { localized("Now Playing") }

    // MARK: - Loading States
    public var buffering: String { localized("Buffering...") }
    public var preparing: String { localized("Preparing...") }
    public var connecting: String { localized("Connecting...") }
    public var downloading: String { localized("Downloading") }

    // MARK: - Error Messages
    public var tryAgain: String { localized("Try Again") }
    public var noMediaSelected: String { localized("No media selected") }
    public var noMediaLoaded: String { localized("No media loaded") }
    public var selectMediaToPlay: String { localized("Select a media file to play") }
    public var invalidOrCorrupted: String { localized("The media file is invalid or corrupted") }
    public var networkError: String { localized("Network error") }
    public var playbackError: String { localized("Playback error") }
    public var unsupportedFormat: String { localized("Unsupported format") }

    // MARK: - Playback State Text
    public var ready: String { localized("Ready") }
    public var willPlay: String { localized("Will Play") }
    public var playing: String { localized("Playing") }
    public var paused: String { localized("Paused") }
    public var stopped: String { localized("Stopped") }
    public var failed: String { localized("Failed") }

    // MARK: - Error Failure Reasons
    public var pleaseSelectMedia: String { localized("Please select a media file to play") }
    public var fileFormatNotSupportedOrCorrupted: String { localized("The file format is not supported or the file is corrupted") }
    public var networkConnectionProblem: String { localized("There was a problem with the network connection") }
    public var playbackProblem: String { localized("There was a problem during playback") }
    public var mediaTypeNotSupported: String { localized("The selected media type is not supported") }

    // MARK: - Error Recovery Suggestions
    public var selectMediaFromLibrary: String { localized("Select a media file from your library") }
    public var tryDifferentMedia: String { localized("Try with a different media file") }
    public var checkInternetConnection: String { localized("Check your internet connection and try again") }
    public var tryReloadMedia: String { localized("Try reloading the media file") }
    public var chooseSupportedFormat: String { localized("Choose a supported audio or video format") }
    public var checkURLFormat: String { localized("Check if the URL format is correct") }
    public var invalidURL: String { localized("Invalid URL") }
    public var invalidURLReason: String { localized("The provided URL is invalid") }

    // MARK: - Button Disabled Reasons
    public var firstTrack: String { localized("This is the first track") }
    public var lastTrack: String { localized("This is the last track") }
    public var previousTrack: String { localized("Previous Track") }
    public var nextTrack: String { localized("Next Track") }
    public var play: String { localized("Play") }
    public var pause: String { localized("Pause") }
    public var likeCurrentMedia: String { localized("Like Current Media") }
    public var unlikeCurrentMedia: String { localized("Unlike Current Media") }
    public var rewindTenSeconds: String { localized("Rewind 10 Seconds") }
    public var forwardTenSeconds: String { localized("Forward 10 Seconds") }
    public var showEventSubscribers: String { localized("Show Event Subscribers") }
    public var openMediaLibrary: String { localized("Open Media Library") }
    public var closeMediaLibrary: String { localized("Close Media Library") }

    // MARK: - Play Mode
    public var sequentialPlay: String { localized("Sequential Play") }
    public var singleTrackLoop: String { localized("Single Track Loop") }
    public var shufflePlay: String { localized("Shuffle Play") }
    public var repeatAll: String { localized("Repeat All") }

    // MARK: - Media Picker
    public var selectMedia: String { localized("Select Media") }
}

// MARK: - SwiftUI Environment Key

struct LocalizationKey: EnvironmentKey {
    static let defaultValue = Localization()
}

public extension EnvironmentValues {
    var localization: Localization {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}

public extension View {
    /// 设置本地化配置
    /// - Parameter localization: 本地化配置对象
    /// - Returns: 应用本地化配置的视图
    func localization(_ localization: Localization) -> some View {
        environment(\.localization, localization)
    }
}

// MARK: - Preview Helper

extension Localization {
    /// 用于预览的本地化实例（中文）
    public static let preview = Localization()
}
