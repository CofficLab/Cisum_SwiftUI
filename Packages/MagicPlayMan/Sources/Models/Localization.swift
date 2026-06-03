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
    public var retry: String { String(localized: "Retry", bundle: bundle) }
    public var loadingWithDots: String { String(localized: "Loading...", bundle: bundle) }
    public var error: String { String(localized: "Error", bundle: bundle) }

    // MARK: - Audio Content
    public var noArtworkAvailable: String { String(localized: "No artwork available", bundle: bundle) }
    public var failedToLoadArtwork: String { String(localized: "Failed to load artwork", bundle: bundle) }

    // MARK: - Format Info
    public var supportedFormats: String { String(localized: "Supported Formats", bundle: bundle) }

    // MARK: - Error / Loading
    public var failedToLoadMedia: String { String(localized: "Failed to Load Media", bundle: bundle) }

    // MARK: - Thumbnail
    public var noArtwork: String { String(localized: "No Artwork", bundle: bundle) }

    // MARK: - Subscribers
    public var eventSubscribers: String { String(localized: "Event Subscribers", bundle: bundle) }
    public var noSubscribersRegistered: String { String(localized: "No subscribers are currently registered.", bundle: bundle) }
    public var noSubscribers: String { String(localized: "No Subscribers", bundle: bundle) }
    public var since: String { String(localized: "Since", bundle: bundle) }

    // MARK: - Play Mode
    public var lightMode: String { String(localized: "Light Mode", bundle: bundle) }
    public var darkMode: String { String(localized: "Dark Mode", bundle: bundle) }

    // MARK: - Buttons
    public var differentSizes: String { String(localized: "Different Sizes", bundle: bundle) }

    // MARK: - Playback State
    public var nowPlaying: String { String(localized: "Now Playing", bundle: bundle) }

    // MARK: - Loading States
    public var buffering: String { String(localized: "Buffering...", bundle: bundle) }
    public var preparing: String { String(localized: "Preparing...", bundle: bundle) }
    public var connecting: String { String(localized: "Connecting...", bundle: bundle) }
    public var downloading: String { String(localized: "Downloading", bundle: bundle) }

    // MARK: - Error Messages
    public var tryAgain: String { String(localized: "Try Again", bundle: bundle) }
    public var noMediaSelected: String { String(localized: "No media selected", bundle: bundle) }
    public var noMediaLoaded: String { String(localized: "No media loaded", bundle: bundle) }
    public var selectMediaToPlay: String { String(localized: "Select a media file to play", bundle: bundle) }
    public var invalidOrCorrupted: String { String(localized: "The media file is invalid or corrupted", bundle: bundle) }
    public var networkError: String { String(localized: "Network error", bundle: bundle) }
    public var playbackError: String { String(localized: "Playback error", bundle: bundle) }
    public var unsupportedFormat: String { String(localized: "Unsupported format", bundle: bundle) }

    // MARK: - Playback State Text
    public var ready: String { String(localized: "Ready", bundle: bundle) }
    public var willPlay: String { String(localized: "Will Play", bundle: bundle) }
    public var playing: String { String(localized: "Playing", bundle: bundle) }
    public var paused: String { String(localized: "Paused", bundle: bundle) }
    public var stopped: String { String(localized: "Stopped", bundle: bundle) }
    public var failed: String { String(localized: "Failed", bundle: bundle) }

    // MARK: - Error Failure Reasons
    public var pleaseSelectMedia: String { String(localized: "Please select a media file to play", bundle: bundle) }
    public var fileFormatNotSupportedOrCorrupted: String { String(localized: "The file format is not supported or the file is corrupted", bundle: bundle) }
    public var networkConnectionProblem: String { String(localized: "There was a problem with the network connection", bundle: bundle) }
    public var playbackProblem: String { String(localized: "There was a problem during playback", bundle: bundle) }
    public var mediaTypeNotSupported: String { String(localized: "The selected media type is not supported", bundle: bundle) }

    // MARK: - Error Recovery Suggestions
    public var selectMediaFromLibrary: String { String(localized: "Select a media file from your library", bundle: bundle) }
    public var tryDifferentMedia: String { String(localized: "Try with a different media file", bundle: bundle) }
    public var checkInternetConnection: String { String(localized: "Check your internet connection and try again", bundle: bundle) }
    public var tryReloadMedia: String { String(localized: "Try reloading the media file", bundle: bundle) }
    public var chooseSupportedFormat: String { String(localized: "Choose a supported audio or video format", bundle: bundle) }
    public var checkURLFormat: String { String(localized: "Check if the URL format is correct", bundle: bundle) }
    public var invalidURL: String { String(localized: "Invalid URL", bundle: bundle) }
    public var invalidURLReason: String { String(localized: "The provided URL is invalid", bundle: bundle) }

    // MARK: - Button Disabled Reasons
    public var firstTrack: String { String(localized: "This is the first track", bundle: bundle) }
    public var lastTrack: String { String(localized: "This is the last track", bundle: bundle) }
    public var previousTrack: String { String(localized: "Previous Track", bundle: bundle) }
    public var nextTrack: String { String(localized: "Next Track", bundle: bundle) }
    public var play: String { String(localized: "Play", bundle: bundle) }
    public var pause: String { String(localized: "Pause", bundle: bundle) }
    public var likeCurrentMedia: String { String(localized: "Like Current Media", bundle: bundle) }
    public var unlikeCurrentMedia: String { String(localized: "Unlike Current Media", bundle: bundle) }
    public var rewindTenSeconds: String { String(localized: "Rewind 10 Seconds", bundle: bundle) }
    public var forwardTenSeconds: String { String(localized: "Forward 10 Seconds", bundle: bundle) }
    public var showEventSubscribers: String { String(localized: "Show Event Subscribers", bundle: bundle) }
    public var openMediaLibrary: String { String(localized: "Open Media Library", bundle: bundle) }
    public var closeMediaLibrary: String { String(localized: "Close Media Library", bundle: bundle) }

    // MARK: - Play Mode
    public var sequentialPlay: String { String(localized: "Sequential Play", bundle: bundle) }
    public var singleTrackLoop: String { String(localized: "Single Track Loop", bundle: bundle) }
    public var shufflePlay: String { String(localized: "Shuffle Play", bundle: bundle) }
    public var repeatAll: String { String(localized: "Repeat All", bundle: bundle) }

    // MARK: - Media Picker
    public var selectMedia: String { String(localized: "Select Media", bundle: bundle) }
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
