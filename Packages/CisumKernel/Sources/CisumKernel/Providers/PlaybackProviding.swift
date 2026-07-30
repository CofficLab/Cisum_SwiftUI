import Foundation
import SwiftUI

/// 播放服务能力协议。
///
/// 提供音频/有声书播放的状态查询与控制接口。
///
/// ## 使用示例
///
/// ```swift
/// kernel.playback?.play()
/// kernel.playback?.pause()
/// let isPlaying = kernel.playback?.isPlaying ?? false
/// ```
@MainActor
public protocol PlaybackProviding: AnyObject, ObservableObject {
    /// 当前是否正在播放。
    var isPlaying: Bool { get }

    /// 当前播放进度 (0.0 ~ 1.0)。
    var progress: Double { get }

    /// 当前播放进度时间。
    var currentTime: TimeInterval { get }

    /// 总时长。
    var duration: TimeInterval { get }

    /// 当前播放资源标题。
    var currentTitle: String { get }

    /// 当前播放资源艺术家。
    var currentArtist: String { get }

    /// 是否有封面图。
    var hasArtwork: Bool { get }

    /// 当前播放模式。
    var playMode: PlayMode { get }

    /// 开始播放。
    func play()

    /// 暂停播放。
    func pause()

    /// 切换播放 / 暂停。
    func togglePlayPause()

    /// 播放下一首。
    func next()

    /// 播放上一首。
    func previous()

    /// 跳转到指定进度。
    ///
    /// - Parameter progress: 0.0 ~ 1.0 的进度值。
    func seek(to progress: Double)

    /// 设置播放模式。
    ///
    /// - Parameter mode: 目标播放模式。
    func setPlayMode(_ mode: PlayMode)
}

/// 播放模式。
public enum PlayMode: String, Sendable, CaseIterable {
    /// 顺序播放。
    case sequence
    /// 随机播放。
    case shuffle
    /// 单曲循环。
    case repeatOne

    public var iconName: String {
        switch self {
        case .sequence: "repeat"
        case .shuffle: "shuffle"
        case .repeatOne: "repeat.1"
        }
    }
}
