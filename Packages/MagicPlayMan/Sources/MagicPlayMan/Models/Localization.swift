import Foundation
import SwiftUI

/// 本地化字符串管理
public struct Localization {
    private let locale: Locale

    public init(locale: Locale) {
        self.locale = locale
    }

    // MARK: - Common
    public var retry: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "重试"
        default: return "Retry"
        }
    }

    public var loadingWithDots: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "加载中..."
        default: return "Loading..."
        }
    }

    public var error: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "错误"
        default: return "Error"
        }
    }

    // MARK: - Audio Content
    public var noArtworkAvailable: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无专辑封面"
        default: return "No artwork available"
        }
    }

    public var failedToLoadArtwork: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "加载封面失败"
        default: return "Failed to load artwork"
        }
    }

    // MARK: - Format Info
    public var supportedFormats: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "支持的格式"
        default: return "Supported Formats"
        }
    }

    // MARK: - Error / Loading
    public var failedToLoadMedia: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "加载媒体失败"
        default: return "Failed to Load Media"
        }
    }

    // MARK: - Thumbnail
    public var noArtwork: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无封面"
        default: return "No Artwork"
        }
    }

    // MARK: - Subscribers
    public var eventSubscribers: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "事件订阅者"
        default: return "Event Subscribers"
        }
    }

    public var noSubscribersRegistered: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "当前没有订阅者"
        default: return "No subscribers are currently registered."
        }
    }

    public var noSubscribers: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无订阅者"
        default: return "No Subscribers"
        }
    }

    public var since: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "始于"
        default: return "Since"
        }
    }

    // MARK: - Play Mode
    public var lightMode: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "浅色模式"
        default: return "Light Mode"
        }
    }

    public var darkMode: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "深色模式"
        default: return "Dark Mode"
        }
    }

    // MARK: - Buttons
    public var differentSizes: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "不同尺寸"
        default: return "Different Sizes"
        }
    }

    // MARK: - Playback State
    public var nowPlaying: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "正在播放"
        default: return "Now Playing"
        }
    }

    // MARK: - Loading States
    public var buffering: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "缓冲中..."
        default: return "Buffering..."
        }
    }

    public var preparing: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "准备中..."
        default: return "Preparing..."
        }
    }

    public var connecting: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "连接中..."
        default: return "Connecting..."
        }
    }

    public var downloading: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "正在下载"
        default: return "Downloading"
        }
    }

    // MARK: - Error Messages
    public var tryAgain: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "重试"
        default: return "Try Again"
        }
    }

    public var noMediaSelected: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "未选择媒体"
        default: return "No media selected"
        }
    }

    public var noMediaLoaded: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "未加载媒体"
        default: return "No media loaded"
        }
    }

    public var selectMediaToPlay: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "选择一个媒体文件开始播放"
        default: return "Select a media file to play"
        }
    }

    public var invalidOrCorrupted: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "媒体文件无效或已损坏"
        default: return "The media file is invalid or corrupted"
        }
    }

    public var networkError: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "网络错误"
        default: return "Network error"
        }
    }

    public var playbackError: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "播放错误"
        default: return "Playback error"
        }
    }

    public var unsupportedFormat: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "不支持的格式"
        default: return "Unsupported format"
        }
    }

    // MARK: - Playback State Text
    public var ready: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "就绪"
        default: return "Ready"
        }
    }

    public var willPlay: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "即将播放"
        default: return "Will Play"
        }
    }

    public var playing: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "播放中"
        default: return "Playing"
        }
    }

    public var paused: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "已暂停"
        default: return "Paused"
        }
    }

    public var stopped: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "已停止"
        default: return "Stopped"
        }
    }

    public var failed: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "失败"
        default: return "Failed"
        }
    }

    // MARK: - Error Failure Reasons
    public var pleaseSelectMedia: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "请选择一个媒体文件来播放"
        default: return "Please select a media file to play"
        }
    }

    public var fileFormatNotSupportedOrCorrupted: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "文件格式不支持或文件已损坏"
        default: return "The file format is not supported or the file is corrupted"
        }
    }

    public var networkConnectionProblem: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "网络连接出现问题"
        default: return "There was a problem with the network connection"
        }
    }

    public var playbackProblem: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "播放期间出现问题"
        default: return "There was a problem during playback"
        }
    }

    public var mediaTypeNotSupported: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "选择的媒体类型不受支持"
        default: return "The selected media type is not supported"
        }
    }

    // MARK: - Error Recovery Suggestions
    public var selectMediaFromLibrary: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "从资料库中选择一个媒体文件"
        default: return "Select a media file from your library"
        }
    }

    public var tryDifferentMedia: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "尝试使用不同的媒体文件"
        default: return "Try with a different media file"
        }
    }

    public var checkInternetConnection: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "检查您的网络连接然后重试"
        default: return "Check your internet connection and try again"
        }
    }

    public var tryReloadMedia: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "尝试重新加载媒体文件"
        default: return "Try reloading the media file"
        }
    }

    public var chooseSupportedFormat: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "选择支持的音频或视频格式"
        default: return "Choose a supported audio or video format"
        }
    }
    public var checkURLFormat: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "检查 URL 格式是否正确"
        default: return "Check if the URL format is correct"
        }
    }

    public var invalidURL: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无效的 URL"
        default: return "Invalid URL"
        }
    }

    public var invalidURLReason: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "提供的 URL 无效"
        default: return "The provided URL is invalid"
        }
    }

    // MARK: - Button Disabled Reasons

    public var firstTrack: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "这是第一首曲目"
        default: return "This is the first track"
        }
    }

    public var lastTrack: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "这是最后一首曲目"
        default: return "This is the last track"
        }
    }

    // MARK: - Play Mode

    public var sequentialPlay: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "顺序播放"
        default: return "Sequential Play"
        }
    }

    public var singleTrackLoop: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "单曲循环"
        default: return "Single Track Loop"
        }
    }

    public var shufflePlay: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "随机播放"
        default: return "Shuffle Play"
        }
    }

    public var repeatAll: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "全部循环"
        default: return "Repeat All"
        }
    }

    // MARK: - Media Picker

    public var selectMedia: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "选择媒体"
        default: return "Select Media"
        }
    }
}

// MARK: - SwiftUI Environment Key

struct LocalizationKey: EnvironmentKey {
    static let defaultValue = Localization(locale: Locale(identifier: "zh_CN"))
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
    public static let preview = Localization(locale: Locale(identifier: "zh_CN"))
}
