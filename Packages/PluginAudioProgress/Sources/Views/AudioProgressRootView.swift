import AVFoundation
import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import PluginAudio
import PluginAudioLike
import ProviderScene
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import WidgetKit

enum AudioProgressPersistencePolicy {
    static func shouldPersistWhenSceneChanges(from oldSceneName: String?, to newSceneName: String?, audioSceneName: String) -> Bool {
        oldSceneName == audioSceneName && newSceneName != audioSceneName
    }

    static func currentURLToStore(_ url: URL?, storedURL: URL?, supportedExtensions: [String]) -> URL? {
        guard let url else { return nil }

        let supportedExtensions = Set(supportedExtensions.map { $0.lowercased() })
        guard supportedExtensions.contains(url.pathExtension.lowercased()) else {
            return storedURL
        }

        return url
    }

    static func shouldResetGlobalTimeWhenCurrentURLChanges(from storedURL: URL?, to newURL: URL?) -> Bool {
        !representsSameFile(storedURL, newURL)
    }

    static func shouldClearRestoredCurrentURL(storedURL: URL?, isPlayable: Bool) -> Bool {
        storedURL != nil && !isPlayable
    }

    static func shouldClearRestoredCurrentTime(storedURL: URL?, isPlayable: Bool) -> Bool {
        shouldClearRestoredCurrentURL(storedURL: storedURL, isPlayable: isPlayable)
    }

    static func shouldClearStoredCurrentAfterDelete(storedURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let storedURL else { return false }
        return deletedURLs.contains { deletedURL in
            storedURL.isSameFileLocation(as: deletedURL)
        }
    }

    static func shouldApplyRestoreResult(startingAsset: URL?, currentAsset: URL?) -> Bool {
        representsSameFile(startingAsset, currentAsset)
    }

    static func shouldApplyRestoreRequest(currentGeneration: Int, requestGeneration: Int, isSceneActive: Bool) -> Bool {
        currentGeneration == requestGeneration && isSceneActive
    }

    static func shouldPlayRestoredAsset(restoredAsset: URL, currentAsset: URL?) -> Bool {
        !representsSameFile(restoredAsset, currentAsset)
    }

    static func shouldApplyCurrentURLChange(requestedURL: URL?, currentAsset: URL?) -> Bool {
        representsSameFile(requestedURL, currentAsset)
    }

    static func shouldApplyCurrentURLChange(
        requestedURL: URL?,
        currentAsset: URL?,
        currentGeneration: Int,
        requestGeneration: Int,
        isSceneActive: Bool
    ) -> Bool {
        currentGeneration == requestGeneration
            && isSceneActive
            && shouldApplyCurrentURLChange(requestedURL: requestedURL, currentAsset: currentAsset)
    }

    static func shouldApplyWidgetMetadataResult(requestedAsset: URL, currentAsset: URL?) -> Bool {
        representsSameFile(requestedAsset, currentAsset)
    }

    static func shouldApplyWidgetClearResult(currentAsset: URL?) -> Bool {
        currentAsset == nil
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return lhs.isSameFileLocation(as: rhs)
        default:
            return false
        }
    }
}

public struct AudioProgressRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "💾" }
    private static var verbose: Bool { false }

    @EnvironmentObject var man: MagicPlayMan
    @State private var restoreGeneration = 0

    private var content: Content
    private let scene: (any SceneProviding)?
    private let audioScene: AppScene
    private let audioRepo: @MainActor () async -> AudioRepo?
    private let storageResetNotifications: [Notification.Name]
    private let saveWidgetData: @Sendable (String, String, Bool, Data?) -> Void

    public init(
        scene: (any SceneProviding)?,
        audioScene: AppScene,
        audioRepo: @escaping @MainActor () async -> AudioRepo?,
        storageResetNotifications: [Notification.Name] = [],
        saveWidgetData: @escaping @Sendable (String, String, Bool, Data?) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.scene = scene
        self.audioScene = audioScene
        self.audioRepo = audioRepo
        self.storageResetNotifications = storageResetNotifications
        self.saveWidgetData = saveWidgetData
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onChange(of: scene?.currentScene) { oldScene, newScene in
                handleCurrentSceneChanged(from: oldScene, to: newScene)
            }
            .onPlayManStateChanged(handlePlayManStateChanged)
            .onPlayManAssetChanged(handlePlayManAssetChanged)
            .onReceive(NotificationCenter.default.publisher(for: .dbDeleted), perform: handleDBDeleted)
            // 注意：存储位置变更时，本RootView会被卸载掉，光靠 onPlayManAssetChanged 无法监听到
            .modifier(AudioProgressStorageResetModifier(notificationNames: storageResetNotifications) {
                handleStorageLocationDidReset()
            })
    }

    /// 检查是否应该激活进度管理功能
    private var shouldActivateProgress: Bool {
        scene?.currentScene == audioScene
    }
}

private struct AudioProgressStorageResetModifier: ViewModifier {
    let notificationNames: [Notification.Name]
    let action: () -> Void

    func body(content: Content) -> some View {
        notificationNames.reduce(AnyView(content)) { partial, name in
            AnyView(partial.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                action()
            })
        }
    }
}

// MARK: - Action

extension AudioProgressRootView {
    /// 恢复播放模式
    ///
    /// 从持久化存储中读取上次的播放模式并应用到播放器。
    /// 播放模式包括：顺序播放、单曲循环、随机播放等。

    /// 恢复上次播放状态
    ///
    /// 从持久化存储中恢复上次播放的音频、播放进度和喜欢状态。
    /// 如果没有上次播放记录，或该文件已不存在，则播放第一首音频。
    ///
    /// ## 恢复流程
    /// 1. 读取上次播放的 URL 和时间
    /// 2. 检查该 URL 是否存在于 AudioRepo
    /// 3. 如果存在，恢复该音频和进度
    /// 4. 如果不存在或没找到记录，播放第一首音频
    /// 5. 恢复喜欢状态
    private func restorePlaying() {
        var assetTarget: URL?
        var timeTarget: TimeInterval = 0
        var liked = false
        let startingAsset = man.currentAsset
        restoreGeneration += 1
        let generation = restoreGeneration

        Task { @MainActor in
            guard isCurrentRestoreRequest(generation) else { return }

            // 从 AudioPlugin 获取 AudioRepo 实例
            guard let repo = await audioRepo() else {
                if Self.verbose {
                    os_log(.error, "\(self.t)❌ Failed to get AudioRepo")
                }
                return
            }

            // 尝试恢复上次播放
            if let url = AudioStateRepo.getCurrent() {
                // 检查该 URL 是否存在于 AudioRepo
                let isPlayable = await repo.find(url) != nil && isPlayableAudioURL(url)

                if isPlayable {
                    // 文件存在，恢复播放
                    assetTarget = url
                    liked = await AudioLikeRepo.shared.isLiked(url: url)

                    if let time = AudioStateRepo.getCurrentTime() {
                        timeTarget = time
                    }

                    if Self.verbose {
                        os_log("\(self.t)✅ Restored playback: \(url.lastPathComponent) @ \(timeTarget)s")
                    }
                } else {
                    if AudioProgressPersistencePolicy.shouldClearRestoredCurrentURL(storedURL: url, isPlayable: isPlayable) {
                        AudioStateRepo.storeCurrent(nil)
                    }
                    if AudioProgressPersistencePolicy.shouldClearRestoredCurrentTime(storedURL: url, isPlayable: isPlayable) {
                        AudioStateRepo.storeCurrentTime(0)
                    }

                    // 文件不存在，播放第一首
                    if Self.verbose {
                        os_log("\(self.t)⚠️ Last played file no longer exists: \(url.lastPathComponent)")
                    }

                    if let firstUrl = await firstPlayableAudio(in: repo) {
                        assetTarget = firstUrl
                        liked = await AudioLikeRepo.shared.isLiked(url: firstUrl)

                        if Self.verbose {
                            os_log("\(self.t)✅ Playing first track: \(firstUrl.lastPathComponent)")
                        }
                    }
                }
            } else {
                if Self.verbose {
                    os_log("\(self.t)⚠️ No previous playback record")
                }
            }

            if let asset = assetTarget {
                guard AudioProgressPersistencePolicy.shouldApplyRestoreResult(
                    startingAsset: startingAsset,
                    currentAsset: man.currentAsset
                ) else {
                    return
                }

                let reason = self.className + ".restorePlaybackData"
                if AudioProgressPersistencePolicy.shouldPlayRestoredAsset(
                    restoredAsset: asset,
                    currentAsset: man.currentAsset
                ) {
                    guard isCurrentRestoreRequest(generation) else { return }
                    await man.play(asset, autoPlay: false, startTime: timeTarget, reason: reason)
                }
                guard isCurrentRestoreRequest(generation) else { return }
                man.setLike(liked, reason: reason)
            } else {
                if Self.verbose {
                    os_log("\(self.t)⚠️ No playback data to restore")
                }
            }
        }
    }

    private func isCurrentRestoreRequest(_ generation: Int) -> Bool {
        AudioProgressPersistencePolicy.shouldApplyRestoreRequest(
            currentGeneration: restoreGeneration,
            requestGeneration: generation,
            isSceneActive: shouldActivateProgress
        )
    }

    private func firstPlayableAudio(in repo: AudioRepo) async -> URL? {
        let urls = await repo.getAll(reason: self.className + ".firstPlayableAudio")
        return urls.first(where: isPlayableAudioURL)
    }

    private func isPlayableAudioURL(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
            && !url.isFolder
            && AudioPlugin.supportedExtensions.contains(url.pathExtension.lowercased())
    }
}

// MARK: - Event Handler

extension AudioProgressRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    ///
    /// ## 初始化流程
    /// 1. 恢复上次播放状态
    /// 2. 恢复播放模式
    func handleOnAppear() {
        restorePlayingIfNeeded(for: scene?.currentScene)
    }

    /// 处理视图消失事件，避免播放中离开页面时丢失最后进度。
    func handleOnDisappear() {
        restoreGeneration += 1

        guard shouldActivateProgress else { return }

        persistCurrentTime(reason: "handleOnDisappear")
    }

    /// 处理当前场景变化，确保从其它场景切到音频场景时也能恢复进度。
    func handleCurrentSceneChanged(from oldScene: AppScene?, to newScene: AppScene?) {
        if newScene != audioScene {
            restoreGeneration += 1
        }

        if AudioProgressPersistencePolicy.shouldPersistWhenSceneChanges(
            from: oldScene?.rawValue,
            to: newScene?.rawValue,
            audioSceneName: audioScene.rawValue
        ) {
            persistCurrentTime(reason: "handleCurrentSceneChanged")
        }

        restorePlayingIfNeeded(for: newScene)
    }

    private func restorePlayingIfNeeded(for sceneValue: AppScene?) {
        guard sceneValue == audioScene else { return }

        self.restorePlaying()
    }

    /// 处理播放器状态变化事件
    ///
    /// 当播放器状态改变时触发（播放/暂停/停止等）。
    /// 在暂停时会保存当前播放进度。
    ///
    /// - Parameter isPlaying: 是否正在播放
    func handlePlayManStateChanged(_ isPlaying: Bool) {
        guard shouldActivateProgress else { return }

        // Sync to Widget
        syncToWidget(url: man.currentAsset, isPlaying: isPlaying)

        if man.state == .paused {
            persistCurrentTime(reason: "handlePlayManStateChanged")
        }
    }

    /// 处理播放资源变化事件
    ///
    /// 当播放器的音频资源改变时触发，保存当前播放的 URL。
    ///
    /// - Parameter url: 新的音频资源 URL，如果为 nil 则表示停止播放
    func handlePlayManAssetChanged(_ url: URL?) {
        guard shouldActivateProgress else { return }

        // Sync to Widget
        syncToWidget(url: url, isPlaying: man.state == .playing)
        let generation = restoreGeneration

        Task {
            guard AudioProgressPersistencePolicy.shouldApplyCurrentURLChange(
                requestedURL: url,
                currentAsset: man.currentAsset,
                currentGeneration: restoreGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateProgress
            ) else {
                return
            }

            let storedURL = AudioStateRepo.getCurrent()
            let urlToStore = AudioProgressPersistencePolicy.currentURLToStore(
                url,
                storedURL: storedURL,
                supportedExtensions: AudioPlugin.supportedExtensions
            )
            AudioStateRepo.storeCurrent(urlToStore)
            if AudioProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: urlToStore) {
                AudioStateRepo.storeCurrentTime(0)
            }
        }
    }

    func handleDBDeleted(_ notification: Notification) {
        guard let deletedURLs = notification.userInfo?["urls"] as? [URL],
              AudioProgressPersistencePolicy.shouldClearStoredCurrentAfterDelete(
                  storedURL: AudioStateRepo.getCurrent(),
                  deletedURLs: deletedURLs
              ) else {
            return
        }

        AudioStateRepo.storeCurrent(nil)
        AudioStateRepo.storeCurrentTime(0)
    }
    
    private func syncToWidget(url: URL?, isPlaying: Bool) {
        guard let url = url else {
            guard AudioProgressPersistencePolicy.shouldApplyWidgetClearResult(currentAsset: man.currentAsset) else {
                return
            }

            saveWidgetData("Not Playing", "Cisum", false, nil)
            return
        }
        
        let title = url.deletingPathExtension().lastPathComponent
        let artist = "Cisum" // Placeholder
        
        Task {
            var coverArt: Data? = nil
            let asset = AVAsset(url: url)
            do {
                let metadata = try await asset.load(.commonMetadata)
                if let artworkItem = metadata.first(where: { $0.commonKey == .commonKeyArtwork }),
                   let data = try await artworkItem.load(.value) as? Data {
                    coverArt = data
                }
            } catch {
                if Self.verbose {
                    os_log(.error, "\(self.t) Failed to load artwork: \(error.localizedDescription)")
                }
            }

            guard AudioProgressPersistencePolicy.shouldApplyWidgetMetadataResult(
                requestedAsset: url,
                currentAsset: man.currentAsset
            ) else {
                return
            }

            saveWidgetData(title, artist, man.state == .playing, coverArt)
        }
    }

    private func persistCurrentTime(reason: String) {
        AudioStateRepo.storeCurrentTime(man.currentTime)

        if Self.verbose {
            os_log("\(self.t)💾 (\(reason)) Saved playback progress: \(man.currentTime)s")
        }
    }

    /// 处理存储位置重置事件
    ///
    /// 当存储位置被重置时，停止当前播放。
    func handleStorageLocationDidReset() {
        guard shouldActivateProgress else { return }

        if Self.verbose {
            os_log("\(self.t)🛑 Storage location reset; recording playback progress")
        }

        persistCurrentTime(reason: "handleStorageLocationDidReset")
    }
}
