import Foundation
import PluginBook

/// 书籍设置的存储位置变化观察者（迁移 Phase 5）。
///
/// 订阅 `BookPluginHost.storageLocationDidChangeNotifications`，
/// 转发到 `BookSettingsViewModel`；取代原
/// `BookSettingsStorageChangeModifier` 的多通知 `.onReceive`。
@MainActor
final class BookSettingsObserver {
    private weak var viewModel: BookSettingsViewModel?
    private var tokens: [NSObjectProtocol] = []

    init(viewModel: BookSettingsViewModel) {
        self.viewModel = viewModel
        for name in BookPluginHost.storageLocationDidChangeNotifications {
            tokens.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.viewModel?.handleStorageLocationChanged() }
            })
        }
    }

    func cancel() {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
}
