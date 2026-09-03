import Foundation

/// 音频进度的数据库删除与存储重置观察者（迁移 Phase 5）。
///
/// 订阅 `.dbDeleted` 与指定的存储重置通知，转发到
/// `AudioProgressViewModel`；取代原 `AudioProgressRootView` 的
/// `.onReceive` 与 `AudioProgressStorageResetModifier`。
@MainActor
final class AudioProgressObserver {
    private weak var viewModel: AudioProgressViewModel?
    private var tokens: [NSObjectProtocol] = []

    init(viewModel: AudioProgressViewModel, storageResetNotifications: [Notification.Name]) {
        self.viewModel = viewModel
        let center = NotificationCenter.default

        tokens.append(center.addObserver(forName: .dbDeleted, object: nil, queue: .main) { [weak self] notification in
            let urls = notification.userInfo?["urls"] as? [URL] ?? []
            Task { @MainActor in self?.viewModel?.handleDBDeleted(deletedURLs: urls) }
        })

        for name in storageResetNotifications {
            tokens.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.viewModel?.handleStorageLocationDidReset() }
            })
        }
    }

    func cancel() {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
}
