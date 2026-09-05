import Foundation
import MagicAlert
import MagicPlayMan
import OSLog
import ProviderScene
import SwiftUI

/// 书籍喜欢设置的集中状态容器（迁移 Phase 5）。
///
/// 持有喜欢列表与加载状态，统一处理加载与喜欢状态变化刷新；
/// 取代原 `BookLikeSettingsView` 内的 `@State` 与 `.onReceive`。
@MainActor
final class BookLikeViewModel: ObservableObject {
    @Published private(set) var likedBooks: [BookLikeItem] = []
    @Published private(set) var isLoading = true

    private weak var playMan: MagicPlayMan?
    private let targetScene: AppScene
    private var isActive = false

    init(targetScene: AppScene = .audiobooks) {
        self.targetScene = targetScene
    }

    func bind(playMan: MagicPlayMan?) {
        self.playMan = playMan
    }

    func handleSceneChange(_ scene: AppScene?) {
        isActive = scene == targetScene
    }

    func handleAppear() {
        loadLikedBooks()
    }

    func handleLikeStatusChanged() {
        loadLikedBooks()
    }

    func handleLikeStatusChanged(asset: URL, liked: Bool) {
        guard isActive else { return }
        BookLikeStore.setLiked(liked, url: asset)
        handleLikeStatusChanged()
        NotificationCenter.postBookLikeStatusChanged(url: asset, liked: liked)
    }

    private func loadLikedBooks() {
        likedBooks = BookLikeStore.likedBooks()
        isLoading = false
    }
}
