import Foundation
import SwiftUI
import CisumUI

/// 本地化字符串管理
public struct Localization {
    private let bundle: Bundle

    public init(locale: Locale = .current) {
        self.bundle = .module
    }

    // MARK: - Common
    public var retry: String { String(localized: "Retry", table: "Localizable", bundle: bundle) }
    public var loadingWithDots: String { String(localized: "Loading...", table: "Localizable", bundle: bundle) }
    public var error: String { String(localized: "Error", table: "Localizable", bundle: bundle) }

    // MARK: - Audio Content
    public var noArtworkAvailable: String { String(localized: "No artwork available", table: "Localizable", bundle: bundle) }
    public var failedToLoadArtwork: String { String(localized: "Failed to load artwork", table: "Localizable", bundle: bundle) }

    // MARK: - Format Info
    public var supportedFormats: String { String(localized: "Supported Formats", table: "Localizable", bundle: bundle) }

    // MARK: - Error / Loading
    public var failedToLoadMedia: String { String(localized: "Failed to Load Media", table: "Localizable", bundle: bundle) }

    // MARK: - Thumbnail
    public var noArtwork: String { String(localized: "No Artwork", table: "Localizable", bundle: bundle) }

    // MARK: - Subscribers
    public var eventSubscribers: String { String(localized: "Event Subscribers", table: "Localizable", bundle: bundle) }
    public var noSubscribersRegistered: String { String(localized: "No subscribers are currently registered.", table: "Localizable", bundle: bundle) }
    public var noSubscribers: String { String(localized: "No Subscribers", table: "Localizable", bundle: bundle) }
    public var since: String { String(localized: "Since", table: "Localizable", bundle: bundle) }

    // MARK: - Play Mode
    public var lightMode: String { String(localized: "Light Mode", table: "Localizable", bundle: bundle) }
    public var darkMode: String { String(localized: "Dark Mode", table: "Localizable", bundle: bundle) }

    // MARK: - Buttons
    public var differentSizes: String { String(localized: "Different Sizes", table: "Localizable", bundle: bundle) }

    // MARK: - Playback State
    public var nowPlaying: String { String(localized: "Now Playing", table: "Localizable", bundle: bundle) }

    // MARK: - Loading States
    public var buffering: String { String(localized: "Buffering...", table: "Localizable", bundle: bundle) }
    public var preparing: String { String(localized: "Preparing...", table: "Localizable", bundle: bundle) }
    public var connecting: String { String(localized: "Connecting...", table: "Localizable", bundle: bundle) }
    public var downloading: String { String(localized: "Downloading", table: "Localizable", bundle: bundle) }

    // MARK: - Error Messages
    public var tryAgain: String { String(localized: "Try Again", table: "Localizable", bundle: bundle) }
    public var noMediaSelected: String { String(localized: "No media selected", table: "Localizable", bundle: bundle) }
    public var noMediaLoaded: String { String(localized: "No media loaded", table: "Localizable", bundle: bundle) }
    public var selectMediaToPlay: String { String(localized: "Select a media file to play", table: "Localizable", bundle: bundle) }
    public var invalidOrCorrupted: String { String(localized: "The media file is invalid or corrupted", table: "Localizable", bundle: bundle) }
    public var networkError: String { String(localized: "Network error", table: "Localizable", bundle: bundle) }
    public var playbackError: String { String(localized: "Playback error", table: "Localizable", bundle: bundle) }
    public var unsupportedFormat: String { String(localized: "Unsupported format", table: "Localizable", bundle: bundle) }

    // MARK: - Playback State Text
    public var ready: String { String(localized: "Ready", table: "Localizable", bundle: bundle) }
    public var willPlay: String { String(localized: "Will Play", table: "Localizable", bundle: bundle) }
    public var playing: String { String(localized: "Playing", table: "Localizable", bundle: bundle) }
    public var paused: String { String(localized: "Paused", table: "Localizable", bundle: bundle) }
    public var stopped: String { String(localized: "Stopped", table: "Localizable", bundle: bundle) }
    public var failed: String { String(localized: "Failed", table: "Localizable", bundle: bundle) }

    // MARK: - Error Failure Reasons
    public var pleaseSelectMedia: String { String(localized: "Please select a media file to play", table: "Localizable", bundle: bundle) }
    public var fileFormatNotSupportedOrCorrupted: String { String(localized: "The file format is not supported or the file is corrupted", table: "Localizable", bundle: bundle) }
    public var networkConnectionProblem: String { String(localized: "There was a problem with the network connection", table: "Localizable", bundle: bundle) }
    public var playbackProblem: String { String(localized: "There was a problem during playback", table: "Localizable", bundle: bundle) }
    public var mediaTypeNotSupported: String { String(localized: "The selected media type is not supported", table: "Localizable", bundle: bundle) }

    // MARK: - Error Recovery Suggestions
    public var selectMediaFromLibrary: String { String(localized: "Select a media file from your library", table: "Localizable", bundle: bundle) }
    public var tryDifferentMedia: String { String(localized: "Try with a different media file", table: "Localizable", bundle: bundle) }
    public var checkInternetConnection: String { String(localized: "Check your internet connection and try again", table: "Localizable", bundle: bundle) }
    public var tryReloadMedia: String { String(localized: "Try reloading the media file", table: "Localizable", bundle: bundle) }
    public var chooseSupportedFormat: String { String(localized: "Choose a supported audio or video format", table: "Localizable", bundle: bundle) }
    public var checkURLFormat: String { String(localized: "Check if the URL format is correct", table: "Localizable", bundle: bundle) }
    public var invalidURL: String { String(localized: "Invalid URL", table: "Localizable", bundle: bundle) }
    public var invalidURLReason: String { String(localized: "The provided URL is invalid", table: "Localizable", bundle: bundle) }

    // MARK: - Button Disabled Reasons
    public var firstTrack: String { String(localized: "This is the first track", table: "Localizable", bundle: bundle) }
    public var lastTrack: String { String(localized: "This is the last track", table: "Localizable", bundle: bundle) }
    public var previousTrack: String { String(localized: "Previous Track", table: "Localizable", bundle: bundle) }
    public var nextTrack: String { String(localized: "Next Track", table: "Localizable", bundle: bundle) }
    public var play: String { String(localized: "Play", table: "Localizable", bundle: bundle) }
    public var pause: String { String(localized: "Pause", table: "Localizable", bundle: bundle) }
    public var likeCurrentMedia: String { String(localized: "Like Current Media", table: "Localizable", bundle: bundle) }
    public var unlikeCurrentMedia: String { String(localized: "Unlike Current Media", table: "Localizable", bundle: bundle) }
    public var rewindTenSeconds: String { String(localized: "Rewind 10 Seconds", table: "Localizable", bundle: bundle) }
    public var forwardTenSeconds: String { String(localized: "Forward 10 Seconds", table: "Localizable", bundle: bundle) }
    public var showEventSubscribers: String { String(localized: "Show Event Subscribers", table: "Localizable", bundle: bundle) }
    public var openMediaLibrary: String { String(localized: "Open Media Library", table: "Localizable", bundle: bundle) }
    public var closeMediaLibrary: String { String(localized: "Close Media Library", table: "Localizable", bundle: bundle) }

    // MARK: - Play Mode
    public var sequentialPlay: String { String(localized: "Sequential Play", table: "Localizable", bundle: bundle) }
    public var singleTrackLoop: String { String(localized: "Single Track Loop", table: "Localizable", bundle: bundle) }
    public var shufflePlay: String { String(localized: "Shuffle Play", table: "Localizable", bundle: bundle) }
    public var repeatAll: String { String(localized: "Repeat All", table: "Localizable", bundle: bundle) }

    // MARK: - Media Picker
    public var selectMedia: String { String(localized: "Select Media", table: "Localizable", bundle: bundle) }
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
