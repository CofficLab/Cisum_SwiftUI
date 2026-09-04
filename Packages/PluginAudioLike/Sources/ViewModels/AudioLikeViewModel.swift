import Combine
import Foundation
import MagicAlert
import MagicPlayMan
import OSLog
import ProviderScene

/// 音频喜欢的集中状态容器（迁移 Phase 2）。
///
/// 统一管理：
/// - 目标场景激活时的播放器「喜欢状态」订阅与保存（原 `AudioLikeRootView` 逻辑）；
/// - 喜欢列表的加载与刷新（原 `AudioLikeSettingsView` 逻辑）。
///
/// 由插件入口持有并注入 `AudioLikeObserver`；View 只展示与转发意图。
@MainActor
final class AudioLikeViewModel: ObservableObject {
    @Published private(set) var likedAudios: [AudioLikeModel] = []
    @Published private(set) var isLoading = true

    private weak var playMan: MagicPlayMan?
    private var playbackSubscriptionID: UUID?
    private var loadGeneration = 0
    private var isActive = false

    func bind(playMan: MagicPlayMan?) {
        self.playMan = playMan
    }

    /// 场景变化：目标场景激活喜欢保存，离开目标场景停用。
    func handleSceneChange(_ sceneValue: AppScene?, targetScene: AppScene) {
        if sceneValue == targetScene {
            activateLike()
        } else {
            deactivateLike()
        }
    }

    /// 重新加载喜欢列表（首次加载与状态变化后刷新）。
    func reloadLikedAudios() {
        loadGeneration += 1
        let generation = loadGeneration

        Task { @MainActor in
            let audios = await AudioLikeRepo.shared.getAllLiked()
            guard generation == self.loadGeneration else { return }
            self.likedAudios = audios
            self.isLoading = false
        }
    }

    // MARK: - Like activation

    private func activateLike() {
        guard !isActive else { return }
        guard let playMan else { return }

        isActive = true
        playbackSubscriptionID = playMan.subscribe(
            name: "AudioLikePlugin",
            onLikeStatusChanged: { [weak self] url, liked in
                self?.handleLikeStatusChanged(url: url, liked: liked)
            }
        )
    }

    private func deactivateLike() {
        guard let playbackSubscriptionID else { return }

        playMan?.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
        isActive = false
    }

    private func handleLikeStatusChanged(url: URL, liked: Bool) {
        guard isActive else { return }

        Task { @MainActor in
            let audioId = url.absoluteString

            do {
                try await AudioLikeRepo.shared.updateLikeStatus(
                    audioId: audioId,
                    liked: liked,
                    url: url,
                    title: url.lastPathComponent
                )

                NotificationCenter.postAudioLikeStatusChanged(audioId: audioId, url: url, liked: liked)
            } catch {
                guard self.isActive else { return }
                os_log(.error, "保存喜欢状态失败: \(error.localizedDescription)")
                alert_error(String(localized: "Failed to save like status: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}
