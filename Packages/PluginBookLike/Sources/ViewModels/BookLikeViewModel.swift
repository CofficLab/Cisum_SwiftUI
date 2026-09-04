import Foundation
import SwiftUI

/// 书籍喜欢设置的集中状态容器（迁移 Phase 5）。
///
/// 持有喜欢列表与加载状态，统一处理加载与喜欢状态变化刷新；
/// 取代原 `BookLikeSettingsView` 内的 `@State` 与 `.onReceive`。
@MainActor
final class BookLikeViewModel: ObservableObject {
    @Published private(set) var likedBooks: [BookLikeItem] = []
    @Published private(set) var isLoading = true

    func handleAppear() {
        loadLikedBooks()
    }

    func handleLikeStatusChanged() {
        loadLikedBooks()
    }

    private func loadLikedBooks() {
        likedBooks = BookLikeStore.likedBooks()
        isLoading = false
    }
}
