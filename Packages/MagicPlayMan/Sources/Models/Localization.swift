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
    public var retry: String { String(localized: "Retry", bundle: .module) }
    public var loadingWithDots: String { String(localized: "Loading...", bundle: .module) }
    public var error: String { String(localized: "Error", bundle: .module) }

    // MARK: - Audio Content
    public var noArtworkAvailable: String { String(localized: "No artwork available", bundle: .module) }
    public var failedToLoadArtwork: String { String(localized: "Failed to load artwork", bundle: .module) }

    // MARK: - Format Info
    public var supportedFormats: String { String(localized: "Supported Formats", bundle: .module) }

    // MARK: - Error / Loading
    public var failedToLoadMedia: String { String(localized: "Failed to Load Media", bundle: .module) }

    // MARK: - Thumbnail
    public var noArtwork: String { String(localized: "No Artwork", bundle: .module) }

    // MARK: - Subscribers
    public var eventSubscribers: String { String(localized: "Event Subscribers", bundle: .module) }
    public var noSubscribersRegistered: String { String(localized: "No subscribers are currently registered.", bundle: .module) }
    public var noSubscribers: String { String(localized: "No Subscribers", bundle: .module) }
    public var since: String { String(localized: "Since", bundle: .module) }

    // MARK: - Play Mode
    public var lightMode: String { String(localized: "Light Mode", bundle: .module) }
    public var darkMode: String { String(localized: "Dark Mode", bundle: .module) }

    // MARK: - Buttons
    public var differentSizes: String { String(localized: "Different Sizes", bundle: .module) }

    // MARK: - Playback State
    public var nowPlaying: String { String(localized: "Now Playing", bundle: .module) }

    // MARK: - Loading States
    public var buffering: String { String(localized: "Buffering...", bundle: .module) }
    public var preparing: String { String(localized: "Preparing...", bundle: .module) }
    public var connecting: String { String(localized: "Connecting...", bundle: .module) }
    public var downloading: String { String(localized: "Downloading", bundle: .module) }

    // MARK: - Error Messages
    public var tryAgain: String { String(localized: "Try Again", bundle: .module) }
    public var noMediaSelected: String { String(localized: "No media selected", bundle: .module) }
    public var noMediaLoaded: String { String(localized: "No media loaded", bundle: .module) }
    public var selectMediaToPlay: String { String(localized: "Select a media file to play", bundle: .module) }
    public var invalidOrCorrupted: String { String(localized: "The media file is invalid or corrupted", bundle: .module) }
    public var networkError: String { String(localized: "Network error", bundle: .module) }
    public var playbackError: String { String(localized: "Playback error", bundle: .module) }
    public var unsupportedFormat: String { String(localized: "Unsupported format", bundle: .module) }

    // MARK: - Playback State Text
    public var ready: String { String(localized: "Ready", bundle: .module) }
    public var willPlay: String { String(localized: "Will Play", bundle: .module) }
    public var playing: String { String(localized: "Playing", bundle: .module) }
    public var paused: String { String(localized: "Paused", bundle: .module) }
    public var stopped: String { String(localized: "Stopped", bundle: .module) }
    public var failed: String { String(localized: "Failed", bundle: .module) }

    // MARK: - Error Failure Reasons
    public var pleaseSelectMedia: String { String(localized: "Please select a media file to play", bundle: .module) }
    public var fileFormatNotSupportedOrCorrupted: String { String(localized: "The file format is not supported or the file is corrupted", bundle: .module) }
    public var networkConnectionProblem: String { String(localized: "There was a problem with the network connection", bundle: .module) }
    public var playbackProblem: String { String(localized: "There was a problem during playback", bundle: .module) }
    public var mediaTypeNotSupported: String { String(localized: "The selected media type is not supported", bundle: .module) }

    // MARK: - Error Recovery Suggestions
    public var selectMediaFromLibrary: String { String(localized: "Select a media file from your library", bundle: .module) }
    public var tryDifferentMedia: String { String(localized: "Try with a different media file", bundle: .module) }
    public var checkInternetConnection: String { String(localized: "Check your internet connection and try again", bundle: .module) }
    public var tryReloadMedia: String { String(localized: "Try reloading the media file", bundle: .module) }
    public var chooseSupportedFormat: String { String(localized: "Choose a supported audio or video format", bundle: .module) }
    public var checkURLFormat: String { String(localized: "Check if the URL format is correct", bundle: .module) }
    public var invalidURL: String { String(localized: "Invalid URL", bundle: .module) }
    public var invalidURLReason: String { String(localized: "The provided URL is invalid", bundle: .module) }

    // MARK: - Button Disabled Reasons
    public var firstTrack: String { String(localized: "This is the first track", bundle: .module) }
    public var lastTrack: String { String(localized: "This is the last track", bundle: .module) }
    public var previousTrack: String { String(localized: "Previous Track", bundle: .module) }
    public var nextTrack: String { String(localized: "Next Track", bundle: .module) }
    public var play: String { String(localized: "Play", bundle: .module) }
    public var pause: String { String(localized: "Pause", bundle: .module) }
    public var likeCurrentMedia: String { String(localized: "Like Current Media", bundle: .module) }
    public var unlikeCurrentMedia: String { String(localized: "Unlike Current Media", bundle: .module) }
    public var rewindTenSeconds: String { String(localized: "Rewind 10 Seconds", bundle: .module) }
    public var forwardTenSeconds: String { String(localized: "Forward 10 Seconds", bundle: .module) }
    public var showEventSubscribers: String { String(localized: "Show Event Subscribers", bundle: .module) }
    public var openMediaLibrary: String { String(localized: "Open Media Library", bundle: .module) }
    public var closeMediaLibrary: String { String(localized: "Close Media Library", bundle: .module) }

    // MARK: - Play Mode
    public var sequentialPlay: String { String(localized: "Sequential Play", bundle: .module) }
    public var singleTrackLoop: String { String(localized: "Single Track Loop", bundle: .module) }
    public var shufflePlay: String { String(localized: "Shuffle Play", bundle: .module) }
    public var repeatAll: String { String(localized: "Repeat All", bundle: .module) }

    // MARK: - Media Picker
    public var selectMedia: String { String(localized: "Select Media", bundle: .module) }
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
