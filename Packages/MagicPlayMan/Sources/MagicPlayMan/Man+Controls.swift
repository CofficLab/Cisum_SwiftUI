import AVFoundation
import Foundation
import MagicKit
import OSLog
import SwiftUI
import CisumUI

enum MagicPlayManPlaybackRequestPolicy {
    static func basicValidationError(for url: URL) -> PlaybackState.PlaybackError? {
        guard url.isFileExist else {
            return .invalidAsset
        }

        guard url.isFileURL || url.isNetworkURL else {
            return .invalidURL(url.scheme ?? "nil")
        }

        guard url.isVideo || url.isAudio else {
            return .unsupportedFormat(url.pathExtension)
        }

        return nil
    }
}

public extension MagicPlayMan {
    /// 设置播放模式
    /// - Parameter mode: 要设置的播放模式
    func changePlayMode(_ mode: MagicPlayMode) {
        Task { @MainActor in
            setPlayMode(mode)
        }
        os_log("\(self.t)Playback mode set to: \(mode.displayName)")
    }

    /// 清理所有缓存
    /// 清除媒体资源缓存，释放磁盘空间
    func clearCache() {
        do {
            try cache?.clear()
            os_log("\(self.t)🗑️ Cache cleared")
        } catch {
            if verbose { os_log("\(self.t)❌ Failed to clear cache: \(error.localizedDescription)") }
        }
    }

    /// 播放下一首
    /// 根据导航订阅者决定播放行为
    func next() {
        guard hasAsset else { return }

        if events.hasNavigationSubscribers {
            if self.verbose {
                os_log("\(self.t)➡️ 请求下一首")
            }

            // 如果有订阅者，发送请求下一首事件
            if let currentAsset = currentURL {
                events.onNextRequested.send(currentAsset)
            }
        } else {
            if self.verbose {
                os_log("\(self.t)➡️ 无 NavigationSubscribers")
            }
        }
    }

    /// 暂停播放
    /// - Parameters:
    ///   - reason: 更新原因
    func pause(reason: String) {
        guard hasAsset else { return }

        if self.verbose {
            os_log("\(self.t)⏸️ (\(reason)) Pause")
        }

        _player.pause()
    }

    /// 开始播放当前加载的媒体资源，如果已播放完毕则从头开始播放
    /// - Parameters:
    ///   - reason: 原因
    func playCurrent(reason: String) {
        guard hasAsset else {
            os_log(.error, "\(self.t)Cannot play: no asset loaded")
            return
        }

        if currentTime == duration {
            self.seek(time: 0, reason: self.className + ".playCurrent")
        }

        // 让内核开始播放，MagicPlayMan初始化时监听了内核状态
        _player.play()
    }

    /// 加载并播放一个 URL
    /// - Parameters:
    ///   - url: 要播放的媒体 URL
    ///   - autoPlay: 是否自动开始播放，默认为 true
    ///   - startTime: 加载完成后定位到的起始时间，默认为 nil
    ///   - reason: 更新原因
    @MainActor
    func play(_ url: URL, autoPlay: Bool = true, startTime: TimeInterval? = nil, reason: String) async {
        if self.verbose {
            os_log("\(self.t)🚀 (\(reason)) Play: \(url.title), AutoPlay: \(autoPlay)")
        }

        // 立即暂停当前播放，避免显示新歌信息但还在放旧歌
        _player.pause()

        if let validationError = MagicPlayManPlaybackRequestPolicy.basicValidationError(for: url) {
            await clearCurrentAssetAfterFailedPlayback(reason: reason + ".validation")
            setState(.failed(validationError), reason: reason + ".play")
            return
        }

        if url.isFileURL {
            let asset = AVURLAsset(url: url)
            do {
                guard try await asset.load(.isPlayable) else {
                    await clearCurrentAssetAfterFailedPlayback(reason: reason + ".unplayable")
                    setState(.failed(.invalidAsset), reason: reason + ".play")
                    return
                }
            } catch {
                await clearCurrentAssetAfterFailedPlayback(reason: reason + ".unplayable")
                setState(.failed(.invalidAsset), reason: reason + ".play")
                return
            }
        }

        self.setCurrentURL(url)

        // 切换资源时清掉旧资源时长，避免新资源加载期间显示上一首的总时长。
        self.setDuration(0)
        self.setProgress(0)
        self.setCurrentTime(0, reason: reason + ".play")

        guard self.currentURL == url else {
            return
        }

        self.setState(.loading(.preparing), reason: reason + ".play")

        if url.isNetworkURL {
            let item = AVPlayerItem(url: url)
            load(item, autoPlay: autoPlay, startTime: startTime, reason: reason)
            return
        }

        downloadAndCache(url, reason: reason) { [weak self] in
            guard let self = self else { return }

            // 关键：确保当前仍是同一个 URL (用户可能在下载期间切歌了)
            guard self.currentURL == url else {
                if self.verbose {
                    os_log("\(self.t)⚠️ URL changed during download, ignoring playback request for: \(url.title)")
                }
                return
            }

            let item = AVPlayerItem(url: url)
            self.load(item, autoPlay: autoPlay, startTime: startTime, reason: reason)
        }
    }

    @MainActor
    func clearCurrentAssetAfterFailedPlayback(reason: String) async {
        _player.replaceCurrentItem(with: nil)
        setCurrentURL(nil)
        setCurrentTime(0, reason: reason)
        setDuration(0)
        setProgress(0)
    }

    /// 播放上一首
    /// 根据导航订阅者决定播放行为
    func previous() {
        guard hasAsset else { return }

        if events.hasNavigationSubscribers {
            // 如果有订阅者，发送请求上一首事件
            if let currentAsset = currentURL {
                events.onPreviousRequested.send(currentAsset)
            }
        }
    }

    /// 跳转到指定时间
    /// - Parameters:
    ///   - time: 目标时间位置（秒）
    ///   - reason: 更新原因
    func seek(time: TimeInterval, reason: String) {
        guard hasAsset else {
            os_log(.error, "\(self.t)⚠️ Cannot seek: no asset loaded")
            return
        }

        if verbose {
            os_log("\(self.t)⏩ (\(reason)) Seeking to \(Int(time))s")
        }
        seekLoadedItem(time: time, reason: reason)
    }

    /// 设置当前资源的喜欢状态
    /// - Parameters:
    ///   - isLiked: 是否喜欢
    ///   - reason: 更新原因
    func setLike(_ isLiked: Bool, reason: String) {
        guard let asset = currentURL else {
            if verbose { os_log("\(self.t)⚠️ Cannot set like: no asset loaded") }
            return
        }

        var newLikedAssets = likedAssets
        if isLiked {
            newLikedAssets.insert(asset)
            if verbose {
                os_log("\(self.t)❤️ (\(reason)) Added to liked: \(asset.title)")
            }
        } else {
            newLikedAssets.remove(asset)
            if verbose {
                os_log("\(self.t)💔 (\(reason)) Removed from liked: \(asset.title)")
            }
        }

        Task { @MainActor in
            setLikedAssets(newLikedAssets)
        }
        // 通知订阅者喜欢状态变化
        events.onLikeStatusChanged.send((asset: asset, isLiked: isLiked))
        updateNowPlayingInfo(includeThumbnail: false, reason: reason + ".setLike")
    }

    /// 静音控制
    /// - Parameter muted: 是否启用静音模式
    func setMuted(_ muted: Bool) {
        _player.isMuted = muted
        os_log("\(self.t)\(muted ? "🔇 Audio muted" : "🔊 Audio unmuted")")
    }

    /// 设置详细日志模式
    /// - Parameter enabled: 是否启用详细的调试日志输出
    func setVerboseMode(_ enabled: Bool) {
        self.verbose = enabled
        os_log("\(self.t)🔍 Verbose mode \(enabled ? "enabled" : "disabled")")
    }

    /// 调整音量
    /// - Parameter volume: 目标音量值，范围 0.0-1.0
    func setVolume(_ volume: Float) {
        _player.volume = max(0, min(1, volume))
        os_log("\(self.t)🔊 Volume set to \(Int(volume * 100))%")
    }

    /// 快退指定时间
    /// - Parameter seconds: 快退的秒数，默认为10秒
    func skipBackward(_ seconds: TimeInterval = 10) {
        seek(time: max(currentTime - seconds, 0), reason: "skipBackward")
        os_log("\(self.t)⏪ Skipped backward \(Int(seconds))s")
    }

    /// 快进指定时间
    /// - Parameter seconds: 快进的秒数，默认为10秒
    func skipForward(_ seconds: TimeInterval = 10) {
        seek(time: currentTime + seconds, reason: "skipForward")
        os_log("\(self.t)⏩ Skipped forward \(Int(seconds))s")
    }

    /// 停止播放
    /// 停止当前播放并将播放位置重置到开始位置
    @MainActor
    func stop(reason: String) async {
        _player.pause()
        await _player.seek(to: .zero)
        setCurrentTime(0, reason: reason)
        setProgress(0)
        setState(.stopped, reason: reason)

        if self.verbose {
            os_log("\(self.t)⏹️ (\(reason)) Stopped playback")
        }
    }

    /// 重置播放器
    /// 完全卸载当前资源，将播放器恢复到初始状态
    /// - Parameter reason: 重置原因（用于日志记录）
    @MainActor
    func reset(reason: String) async {
        // 停止播放
        _player.pause()

        // 清除 AVPlayer 的当前项
        _player.replaceCurrentItem(with: nil)

        // 重置所有状态
        setCurrentURL(nil)
        setCurrentTime(0, reason: reason)
        setDuration(0)
        setProgress(0)
        setState(.idle, reason: reason)

        if self.verbose {
            os_log("\(self.t)🔄 (\(reason)) Player reset to initial state")
        }
    }

    /// 切换当前资源的喜欢状态
    /// 在喜欢和不喜欢之间切换当前播放资源的喜欢状态
    func toggleLike() {
        guard let asset = currentURL else { return }
        setLike(!likedAssets.contains(asset), reason: "toggleLike")
    }

    /// 切换播放状态
    /// 根据当前播放状态在播放/暂停之间切换，如果当前正在播放则暂停，如果当前已暂停或停止则开始播放
    /// - Parameter reason: 切换操作的原因描述
    func toggle(reason: String) {
        switch state {
        case .playing:
            pause(reason: reason)
        case .paused, .stopped:
            playCurrent(reason: reason)
        case .loading, .failed, .idle, .willPlay:
            // 在这些状态下不执行任何操作
            if verbose { os_log("\(self.t)Cannot toggle playback in current state: \(self.state.stateText)") }
            break
        }
    }
}

private extension MagicPlayMan {
    @MainActor
    func load(_ item: AVPlayerItem, autoPlay: Bool, startTime: TimeInterval?, reason: String) {
        _player.replaceCurrentItem(with: item)

        guard let startTime, startTime > 0 else {
            if autoPlay {
                playCurrent(reason: reason + ".play")
            }
            return
        }

        seekLoadedItem(time: startTime, reason: reason + ".load") { [weak self] in
            guard let self else { return }
            if autoPlay {
                self.playCurrent(reason: reason + ".play")
            }
        }
    }

    func seekLoadedItem(time: TimeInterval, reason: String, completion: (() -> Void)? = nil) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        _player.seek(to: targetTime) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                // 更新 Now Playing Info 中的播放时间，否则控制中心/锁屏界面的进度条不会更新
                self.updateNowPlayingInfo(includeThumbnail: true, reason: reason + ".seek")
                completion?()
            }
        }
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}
