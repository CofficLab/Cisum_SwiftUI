import Foundation
import PluginBook

/// 书籍数据库事件的集中观察者（迁移 Phase 3）。
///
/// 订阅数据库同步/更新/删除/排序/播放状态通知，转发到
/// `BookGridViewModel`；取代 `BookGrid` 的 `onBookDB*` 修饰符与
/// `BookTile` 的 `.onReceive(.bookStateUpdated)` 直接订阅。
@MainActor
final class BookDatabaseObserver {
    private weak var viewModel: BookGridViewModel?
    private var tokens: [NSObjectProtocol] = []

    init(viewModel: BookGridViewModel) {
        self.viewModel = viewModel

        let center = NotificationCenter.default
        tokens.append(center.addObserver(forName: .bookDBSyncing, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBSyncing() }
        })
        tokens.append(center.addObserver(forName: .bookDBSynced, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBSynced() }
        })
        tokens.append(center.addObserver(forName: .bookDBUpdated, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBUpdated() }
        })
        tokens.append(center.addObserver(forName: .bookDBDeleted, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBDeleted() }
        })
        tokens.append(center.addObserver(forName: .bookDBSorting, object: nil, queue: .main) { [weak self] _ in
            // 排序开始暂无需 ViewModel 动作（与音频不同，书籍排序无 UI 状态）
        })
        tokens.append(center.addObserver(forName: .bookDBSortDone, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBSortDone() }
        })
        tokens.append(center.addObserver(forName: .bookStateUpdated, object: nil, queue: .main) { [weak self] notification in
            let url = notification.userInfo?["url"] as? URL
            Task { @MainActor in self?.viewModel?.handleBookStateUpdated(url) }
        })
    }

    func cancel() {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
}
