import Foundation

/// 音频喜欢状态通知的集中观察者（迁移 Phase 2）。
///
/// 订阅 `.AudioLikeStatusChanged` 通知，驱动 `AudioLikeViewModel`
/// 刷新喜欢列表；取代 `AudioLikeSettingsView` 直接 `.onReceive` 订阅。
@MainActor
final class AudioLikeObserver {
    private weak var viewModel: AudioLikeViewModel?
    private var token: NSObjectProtocol?

    init(viewModel: AudioLikeViewModel) {
        self.viewModel = viewModel
        token = NotificationCenter.default.addObserver(
            forName: .AudioLikeStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.viewModel?.reloadLikedAudios()
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
