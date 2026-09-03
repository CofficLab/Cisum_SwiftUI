import Foundation
import PluginBook

/// 书籍进度的数据库删除观察者（迁移 Phase 5）。
///
/// 订阅 `.bookDBDeleted` 通知，转发到 `BookProgressViewModel`；
/// 取代原 `BookProgressRootView` 的 `.onReceive` 直接订阅。
@MainActor
final class BookProgressObserver {
    private weak var viewModel: BookProgressViewModel?
    private var token: NSObjectProtocol?

    init(viewModel: BookProgressViewModel) {
        self.viewModel = viewModel
        token = NotificationCenter.default.addObserver(forName: .bookDBDeleted, object: nil, queue: .main) { [weak self] notification in
            let urls = notification.userInfo?["urls"] as? [URL] ?? []
            Task { @MainActor in self?.viewModel?.handleBookDBDeleted(deletedURLs: urls) }
        }
    }

    func cancel() {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
    }
}
