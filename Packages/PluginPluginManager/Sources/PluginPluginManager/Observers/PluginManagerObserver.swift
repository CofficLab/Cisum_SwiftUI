import Foundation
import KernelCore

/// 插件启停变化的集中观察者（迁移 Phase 4）。
///
/// 订阅 `.cisumEnabledPluginsDidChange` 通知，驱动
/// `PluginManagementViewModel.incrementRevision()`；取代原
/// `PluginManagementView` 的直接 `.onReceive` 订阅。
@MainActor
final class PluginManagerObserver {
    private weak var viewModel: PluginManagementViewModel?
    private var token: NSObjectProtocol?

    init(viewModel: PluginManagementViewModel) {
        self.viewModel = viewModel
        token = NotificationCenter.default.addObserver(
            forName: .cisumEnabledPluginsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.viewModel?.incrementRevision()
            }
        }
    }

    func cancel() {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
    }
}
