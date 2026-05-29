import Foundation
import SwiftUI

public enum PlaybackState: Equatable {
    case idle
    case loading(LoadingState)
    case willPlay
    case playing
    case paused
    case stopped
    case failed(PlaybackError)
    
    public enum LoadingState: Equatable {
        case connecting
        case preparing
        case buffering
        case downloading(Double)
    }
    
    public enum PlaybackError: LocalizedError, Equatable {
        case noAsset
        case invalidAsset
        case networkError(String)
        case playbackError(String)
        case unsupportedFormat(String)
        case invalidURL(String)

        public var errorDescription: String? {
            switch self {
            case .noAsset:
                return "No media selected"
            case .invalidAsset:
                return "The media file is invalid or corrupted"
            case .networkError(let message):
                return "Network error: \(message)"
            case .playbackError(let message):
                return "Playback error: \(message)"
            case .unsupportedFormat(let ext):
                return "Unsupported format: \(ext)"
            case .invalidURL(let url):
                return "Invalid URL: \(url)"
            }
        }

        /// 获取本地化的错误描述
        public func localizedDescription(localization: Localization) -> String {
            switch self {
            case .noAsset:
                return localization.noMediaSelected
            case .invalidAsset:
                return localization.invalidOrCorrupted
            case .networkError(let message):
                return "\(localization.networkError): \(message)"
            case .playbackError(let message):
                return "\(localization.playbackError): \(message)"
            case .unsupportedFormat(let ext):
                return "\(localization.unsupportedFormat): \(ext)"
            case .invalidURL(let url):
                return "\(localization.invalidURL): \(url)"
            }
        }

        /// 获取本地化的失败原因
        public func localizedFailureReason(localization: Localization) -> String {
            switch self {
            case .noAsset:
                return localization.pleaseSelectMedia
            case .invalidAsset:
                return localization.fileFormatNotSupportedOrCorrupted
            case .networkError:
                return localization.networkConnectionProblem
            case .playbackError:
                return localization.playbackProblem
            case .unsupportedFormat:
                return localization.mediaTypeNotSupported
            case .invalidURL:
                return localization.invalidURLReason
            }
        }

        /// 获取本地化的恢复建议
        public func localizedRecoverySuggestion(localization: Localization) -> String {
            switch self {
            case .noAsset:
                return localization.selectMediaFromLibrary
            case .invalidAsset:
                return localization.tryDifferentMedia
            case .networkError:
                return localization.checkInternetConnection
            case .playbackError:
                return localization.tryReloadMedia
            case .unsupportedFormat:
                return localization.chooseSupportedFormat
            case .invalidURL:
                return localization.checkURLFormat
            }
        }

        public var failureReason: String? {
            switch self {
            case .noAsset:
                return "Please select a media file to play"
            case .invalidAsset:
                return "The file format is not supported or the file is corrupted"
            case .networkError:
                return "There was a problem with the network connection"
            case .playbackError:
                return "There was a problem during playback"
            case .unsupportedFormat:
                return "The selected media type is not supported"
            case .invalidURL:
                return "The provided URL is invalid"
            }
        }

        public var recoverySuggestion: String? {
            switch self {
            case .noAsset:
                return "Select a media file from your library"
            case .invalidAsset:
                return "Try with a different media file"
            case .networkError:
                return "Check your internet connection and try again"
            case .playbackError:
                return "Try reloading the media file"
            case .unsupportedFormat:
                return "Choose a supported audio or video format"
            case .invalidURL:
                return "Check if the URL format is correct"
            }
        }
    }

    // MARK: - Is

    public var isPlaying: Bool {
        if case .playing = self {
            return true
        }
        return false
    }
    
    /// 是否是加载中
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    /// 是否是下载中
    public var isDownloading: Bool {
        if case .loading(let loadingState) = self {
            if case .downloading = loadingState {
                return true
            }
        }
        return false
    }

    /// 是否是未支持的格式
    public var isUnsupportedFormat: Bool {
        if case .failed(let error) = self {
            if case .unsupportedFormat = error {
                return true
            }
        }
        return false
    }
    
    /// 是否可以 seek
    public var canSeek: Bool {
        switch self {
        case .idle, .loading, .failed:
            return false
        case .willPlay, .playing, .paused, .stopped:
            return true
        }
    }
    
    /// 状态图标名称
    public var iconName: String {
        switch self {
        case .idle:
            return "circle.dashed"
        case .loading:
            return "arrow.clockwise"
        case .willPlay:
            return "play.circle"
        case .playing:
            return "play.circle.fill"
        case .paused:
            return "pause.circle.fill"
        case .stopped:
            return "stop.circle.fill"
        case .failed:
            return "exclamationmark.circle.fill"
        }
    }
    
    /// 状态图标颜色
    public var iconColor: Color {
        switch self {
        case .idle:
            return .secondary
        case .loading:
            return .blue
        case .willPlay:
            return .blue
        case .playing:
            return .green
        case .paused, .stopped:
            return .primary
        case .failed:
            return .red
        }
    }
    
    /// 状态文本
    public var stateText: String {
        switch self {
        case .idle:
            return "Ready"
        case .loading(let loadingState):
            switch loadingState {
            case .connecting:
                return "Connecting..."
            case .preparing:
                return "Preparing..."
            case .buffering:
                return "Buffering..."
            case .downloading(let progress):
                return "Downloading... \(Int(progress * 100))%"
            }
        case .willPlay:
            return "Will Play"
        case .playing:
            return "Playing"
        case .paused:
            return "Paused"
        case .stopped:
            return "Stopped"
        case .failed:
            return "Failed"
        }
    }
    
    // MARK: - View Builder

    /// 创建状态视图
    public func makeStateView(assetTitle: String? = nil, localization: Localization) -> some View {
        StateView(state: self, assetTitle: assetTitle, localization: localization)
    }

    /// 获取本地化的错误描述
    func localizedErrorDescription(localization: Localization) -> String? {
        guard case .failed(let error) = self else { return nil }
        return error.localizedDescription(localization: localization)
    }

    /// 获取本地化的状态文本
    public func localizedStateText(localization: Localization) -> String {
        switch self {
        case .idle:
            return localization.ready
        case .loading(let loadingState):
            switch loadingState {
            case .connecting:
                return localization.connecting
            case .preparing:
                return localization.preparing
            case .buffering:
                return localization.buffering
            case .downloading(let progress):
                return "\(localization.downloading) \(Int(progress * 100))%"
            }
        case .willPlay:
            return localization.willPlay
        case .playing:
            return localization.playing
        case .paused:
            return localization.paused
        case .stopped:
            return localization.stopped
        case .failed:
            return localization.failed
        }
    }
}

// MARK: - State View

/// 状态视图
public struct StateView: View {
    let state: PlaybackState
    let assetTitle: String?
    let localization: Localization
    
    public var body: some View {
        HStack(spacing: 12) {
            // 状态图标
            Image(systemName: state.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(state.iconColor)
                .symbolEffect(.pulse, options: .repeating, value: isAnimated)
            
            VStack(alignment: .leading, spacing: 4) {
                // 状态文本
                Text(state.localizedStateText(localization: localization))
                    .font(.subheadline)
                    .foregroundStyle(state.iconColor)
                
                // 如果有资源标题，显示在下方
                if let title = assetTitle {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 如果是加载状态，显示进度
                if case .loading(let loadingState) = state {
                    if case .downloading(let progress) = loadingState {
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                    } else {
                        ProgressView()
                            .progressViewStyle(.linear)
                            .opacity(0.5)
                    }
                }
                
                // 如果是错误状态，显示错误信息
                if case .failed(let error) = state {
                    Text(error.localizedDescription(localization: localization))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Properties
    
    private var isAnimated: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
}

// MARK: - Preview
#Preview("PlaybackState Views") {
    let localization = Localization(locale: Locale(identifier: "zh_CN"))
    return VStack(spacing: 20) {
        PlaybackState.idle.makeStateView(localization: localization)
        PlaybackState.loading(.connecting).makeStateView(assetTitle: "Test Media", localization: localization)
        PlaybackState.loading(.downloading(0.45)).makeStateView(assetTitle: "Downloading...", localization: localization)
        PlaybackState.willPlay.makeStateView(assetTitle: "Ready to Play", localization: localization)
        PlaybackState.playing.makeStateView(assetTitle: "Now Playing", localization: localization)
        PlaybackState.paused.makeStateView(assetTitle: "Paused Media", localization: localization)
        PlaybackState.stopped.makeStateView(localization: localization)
        PlaybackState.failed(.networkError("Connection timeout")).makeStateView(localization: localization)
    }
    .padding()
    .frame(height: 700)
}
