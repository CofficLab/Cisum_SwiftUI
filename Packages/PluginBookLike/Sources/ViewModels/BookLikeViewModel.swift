import Combine
import Foundation
import MagicAlert
import OSLog
import ProviderScene
import SwiftUI

/// 喜欢列表加载闭包（由插件入口组装本地仓库）。
typealias BookLikeLoadProvider = @MainActor () -> [BookLikeItem]

/// 喜欢状态保存闭包（由插件入口组装本地仓库）。
typealias BookLikeSaveProvider = @MainActor (_ liked: Bool, _ url: URL) -> Void

/// 书籍喜欢设置的集中状态容器（迁移 Phase 5）。
///
/// 统一管理：
/// - 目标场景激活时的播放器「喜欢状态」订阅与保存（原 `BookLikeRootView` 逻辑）；
/// - 喜欢列表的加载与刷新（原 `BookLikeSettingsView` 逻辑）。
///
/// 由插件入口持有并注入 `BookLikeObserver`；View 只展示与转发意图。
/// ViewModel 不直接持有 Kernel 或具体 Provider：播放服务可用性通过
/// `BookLikePlaybackCapability` 表达，本地喜欢仓库由插件入口组装为闭包注入。
@MainActor
final class BookLikeViewModel: ObservableObject {
    @Published private(set) var likedBooks: [BookLikeItem] = []
    @Published private(set) var isLoading = true

    private let playbackCapability: (any BookLikePlaybackCapability)?
    private let loadLikedBooks: BookLikeLoadProvider
    private let saveLikeStatus: BookLikeSaveProvider
    private let targetScene: AppScene
    private var isActive = false

    init(
        targetScene: AppScene = .audiobooks,
        playbackCapability: (any BookLikePlaybackCapability)?,
        loadLikedBooks: @escaping BookLikeLoadProvider,
        saveLikeStatus: @escaping BookLikeSaveProvider
    ) {
        self.targetScene = targetScene
        self.playbackCapability = playbackCapability
        self.loadLikedBooks = loadLikedBooks
        self.saveLikeStatus = saveLikeStatus
    }

    /// 场景变化：目标场景激活喜欢保存，离开目标场景停用。
    func handleSceneChange(_ sceneValue: AppScene?) {
        if sceneValue == targetScene {
            activateLike()
        } else {
            deactivateLike()
        }
    }

    func handleAppear() {
        reloadLikedBooks()
    }

    func handleLikeStatusChanged() {
        reloadLikedBooks()
    }

    func handleLikeStatusChanged(asset: URL, liked: Bool) {
        guard isActive else { return }

        saveLikeStatus(liked, asset)
        handleLikeStatusChanged()
        NotificationCenter.postBookLikeStatusChanged(url: asset, liked: liked)
    }

    /// 重新加载喜欢列表（首次加载与状态变化后刷新）。
    func reloadLikedBooks() {
        likedBooks = loadLikedBooks()
        isLoading = false
    }

    // MARK: - Like activation

    private func activateLike() {
        guard !isActive else { return }
        guard playbackCapability?.isAvailable == true else { return }

        isActive = true
        // Playback events are adapted by BookLikeObserver.
    }

    private func deactivateLike() {
        isActive = false
    }
}
