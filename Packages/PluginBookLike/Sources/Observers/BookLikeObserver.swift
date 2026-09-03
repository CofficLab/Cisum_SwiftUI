import Foundation

/// 书籍喜欢状态变化观察者（迁移 Phase 5）。
///
/// 订阅 `.BookLikeStatusChanged` 通知，转发到 `BookLikeViewModel`；
/// 取代原 `BookLikeSettingsView` 的 `.onReceive` 直接订阅。
@MainActor
final class BookLikeObserver {
    private weak var viewModel: BookLikeViewModel?
    private var token: NSObjectProtocol?

    init(viewModel: BookLikeViewModel) {
        self.viewModel = viewModel
        token = NotificationCenter.default.addObserver(forName: .BookLikeStatusChanged, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleLikeStatusChanged() }
        }
    }

    func cancel() {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
    }
}
