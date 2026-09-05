import Foundation
import ProviderPlayback
import ProviderScene

/// 音频控制的数据库删除与存储重置观察者（迁移 Phase 5）。
///
/// 订阅 `dbDeleted` 与 `storageLocationDidReset` 通知，转发到
/// `AudioControlViewModel`；取代原 `AudioControlRootView` 的
/// 两个 `.onReceive` 直接订阅。
@MainActor
final class AudioControlObserver {
    private weak var viewModel: AudioControlViewModel?
    private var tokens: [NSObjectProtocol] = []
    private var sceneHandle: (any SceneProvidingObserverHandle)?
    private var playbackHandle: (any PlaybackProvidingObserverHandle)?

    init(
        scene: any SceneProviding,
        playback: any PlaybackProviding,
        viewModel: AudioControlViewModel
    ) {
        self.viewModel = viewModel
        viewModel.handleSceneChange(scene.currentScene)

        sceneHandle = scene.addObserver { [weak self] event in
            guard case .selectionChanged(let scene) = event else { return }
            self?.viewModel?.handleSceneChange(scene)
        }
        playbackHandle = playback.addObserver { [weak self] event in
            guard let self else { return }
            switch event {
            case .previousRequested(let asset):
                self.viewModel?.handlePreviousRequested(asset)
            case .nextRequested(let asset):
                self.viewModel?.handleNextRequested(asset)
            default:
                break
            }
        }

        let center = NotificationCenter.default
        tokens.append(center.addObserver(forName: Notification.Name("dbDeleted"), object: nil, queue: .main) { [weak self] notification in
            let urls = notification.userInfo?["urls"] as? [URL] ?? []
            Task { @MainActor in self?.viewModel?.handleDBDeleted(urlsToDelete: urls) }
        })
        tokens.append(center.addObserver(forName: Notification.Name("storageLocationDidReset"), object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleStorageLocationDidReset() }
        })
    }

    func cancel() {
        sceneHandle?.cancel()
        sceneHandle = nil
        playbackHandle?.cancel()
        playbackHandle = nil
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
}
