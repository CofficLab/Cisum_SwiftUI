import AVFoundation
import Combine
import Foundation
import MagicKit
import MediaPlayer
import OSLog
import SwiftUI

public extension MagicPlayMan {
    /// 初始化播放器
    /// - Parameters:
    ///   - cacheDirectory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录
    ///   - playlistEnabled: 是否启用播放列表，默认为 true
    ///   - verbose: 是否启用详细日志模式，默认为 false
    ///   - locale: 本地化设置，默认为中文
    ///   - defaultArtwork: 默认封面图，用于在音频缩略图无法获得时显示
    ///   - defaultArtworkBuilder: 默认封面图构建器，支持自定义视图作为默认封面
    convenience init(
        cacheDirectory: URL? = nil,
        verbose: Bool = false,
        locale: Locale = Locale(identifier: "zh_CN"),
        defaultArtwork: Image? = nil,
        defaultArtworkBuilder: (() -> any View)? = nil
    ) {
        self.init()

        // 设置本地化
        self.localization = Localization(locale: locale)

        if verbose {
            os_log("\(self.t)🌍 Localization: \(locale.identifier)")
        }

        // 设置默认封面图
        self.defaultArtwork = defaultArtwork
        self.defaultArtworkBuilder = defaultArtworkBuilder

        // 设置详细日志模式
        self.verbose = verbose
        if verbose {
            os_log("\(self.t)📢 Verbose mode enabled")
        }

        // 初始化缓存，如果失败则禁用缓存功能
        do {
            self.cache = try AssetCache(directory: cacheDirectory)
            if let cacheDir = self.cache?.directory {
                if verbose {
                    os_log("\(self.t)📁 缓存目录: \(cacheDir.path)")
                }
            }
        } catch {
            self.cache = nil
            if verbose {
                os_log("\(self.t)Cache disabled")
            }
        }

        // 完成初始化后再设置其他内容
        setupPlayer()
        setupObservers()
        setupRemoteControl()
    }
}

// MARK: - Internal Setup Methods

internal extension MagicPlayMan {
    /// 设置播放器
    func setupPlayer() {
        timeObserver = _player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            let currentTime = time.seconds
            let progress = self.duration > 0 ? currentTime / self.duration : 0

            // 更新内部状态并发送通知
            self.setCurrentTime(currentTime, reason: self.className + ".setupPlayer")
            self.setProgress(progress)
        }
    }

    /// 设置观察者
    func setupObservers() {
        // 监听内部的Player的播放状态
        _player.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { @MainActor in
                    switch status {
                    case .readyToPlay:
                        self.setState(.paused, reason: self.className + ".systemObserver.readyToPlay")
                        // 资源准备好后更新 Now Playing Info
                        self.updateNowPlayingInfo(includeThumbnail: true, reason: self.className + ".systemObserver.readyToPlay")
                    @unknown default:
                        break
                    }
                }
            }
            .store(in: &cancellables)

        _player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { @MainActor in
                    switch status {
                    case .playing:
                        self.setState(.playing, reason: self.className + ".systemObserver")
                        // 播放状态变化时更新 Now Playing Info
                        self.updateNowPlayingInfo(includeThumbnail: true, reason: self.className + ".systemObserver.playing")
                    case .paused:
                        self.updateNowPlayingInfo(includeThumbnail: false, reason: self.className + ".systemObserver.paused")

                        // 如果是下载状态，无需更新状态
                        if self.state.isDownloading {
                            return
                        }

                        self.setState(self.currentTime == 0 ? .stopped : .paused, reason: self.className + ".systemObserver.paused")
                    case .waitingToPlayAtSpecifiedRate:
                        if case .playing = self.state {
                            self.setState(.loading(.buffering), reason: self.className + ".systemObserver.waitingToPlayAtSpecifiedRate")
                        }
                    @unknown default:
                        break
                    }
                }
            }
            .store(in: &cancellables)

        // 监听缓冲状态
        _player.publisher(for: \.currentItem?.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                guard let self = self else { return }
                if let isEmpty = isEmpty {
                    Task { @MainActor in
                        if isEmpty, case .playing = self.state {
                            self.setState(.loading(.buffering), reason: "bufferObserver")
                        } else if !isEmpty, case .loading(.buffering) = self.state {
                            self.setState(.playing, reason: "bufferObserver")
                        }
                    }
                }
            }
            .store(in: &cancellables)

        // 监听资源时长变化
        _player.publisher(for: \.currentItem?.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                guard let self = self, let duration = duration else { return }
                let durationInSeconds = duration.seconds
                // 只有在时长有效且发生变化时才更新
                if durationInSeconds.isFinite && durationInSeconds > 0 {
                    Task { @MainActor in
                        self.setDuration(durationInSeconds)
                    }
                }
            }
            .store(in: &cancellables)

        // 监听播放完成
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                if let currentAsset = self.currentURL {
                    if verbose {
                        os_log("\(self.t)✅ 播放完成：\(currentAsset.title)")
                    }

                    // 如果是单曲循环模式，重新播放当前曲目
                    if self.playMode == .loop {
                        if verbose {
                            os_log("\(self.t)单曲循环模式，重新播放：\(currentAsset.title)")
                        }
                        Task { @MainActor in
                            self.playCurrent(reason: "单曲循环模式，重新播放")
                        }
                        return
                    }

                    // 播放完成后，通知订阅者
                    if verbose {
                        os_log("\(self.t)🌹 播放完成，等待订阅者处理下一首")
                    }
                    Task { @MainActor in
                        self.setState(.stopped, reason: "playbackFinished")
                    }
                    self.events.onNextRequested.send(currentAsset)
                }
            }
            .store(in: &cancellables)
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}
