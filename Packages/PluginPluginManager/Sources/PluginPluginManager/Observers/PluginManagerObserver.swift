import Foundation
import ProviderPluginManaging

/// 插件启停变化的集中观察者（迁移 Phase 4）。
///
/// 订阅 `PluginManaging` Provider 的 `enabledPluginsChanged` 语义事件，驱动
/// `PluginManagementViewModel.incrementRevision()`；取代原 `PluginManagementView`
/// 的直接 `.onReceive` 订阅与对 `.cisumEnabledPluginsDidChange` 通知的直接监听。
@MainActor
final class PluginManagerObserver {
    private weak var viewModel: PluginManagementViewModel?
    private var handle: (any PluginManagingObserverHandle)?

    init(manager: any PluginManaging, viewModel: PluginManagementViewModel) {
        self.viewModel = viewModel
        handle = manager.addObserver { [weak self] _ in
            self?.viewModel?.incrementRevision()
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
