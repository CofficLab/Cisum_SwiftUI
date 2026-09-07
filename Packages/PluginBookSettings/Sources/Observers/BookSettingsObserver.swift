import Foundation
import OSLog
import PluginBook
import MagicKit

/// 书籍设置的存储位置变化观察者（迁移 Phase 5）。
///
/// 订阅 `BookPluginHost.storageLocationDidChangeNotifications`，
/// 转发到 `BookSettingsViewModel`；取代原
/// `BookSettingsStorageChangeModifier` 的多通知 `.onReceive`。
@MainActor
final class BookSettingsObserver: SuperLog {
    nonisolated static let verbose = true

    private weak var viewModel: BookSettingsViewModel?
    private var tokens: [NSObjectProtocol] = []

    init(viewModel: BookSettingsViewModel) {
        self.viewModel = viewModel
        if Self.verbose { os_log("\(Self.t)👀 BookSettingsObserver 初始化") }
        for name in BookPluginHost.storageLocationDidChangeNotifications {
            tokens.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.viewModel?.handleStorageLocationChanged() }
            })
        }
    }

    func cancel() {
        if Self.verbose { os_log("\(Self.t)🧹 BookSettingsObserver 取消") }
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
}
