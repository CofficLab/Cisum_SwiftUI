import Foundation
import MagicPlayMan
import PluginBook
import ProviderPlayback
import ProviderScene

/// 书籍进度的数据库删除观察者（迁移 Phase 5）。
///
/// 订阅 `.bookDBDeleted` 通知，转发到 `BookProgressViewModel`；
/// 取代原 `BookProgressRootView` 的 `.onReceive` 直接订阅。
@MainActor
final class BookProgressObserver {
    private weak var viewModel: BookProgressViewModel?
    private var token: NSObjectProtocol?
    private var sceneHandle: (any SceneProvidingObserverHandle)?
    private var playbackHandle: (any PlaybackProvidingObserverHandle)?
    private var currentScene: AppScene?

    init(scene: any SceneProviding, playback: any PlaybackProviding, viewModel: BookProgressViewModel) {
        self.viewModel = viewModel
        viewModel.bind(playMan: playback as? MagicPlayMan)
        currentScene = scene.currentScene
        viewModel.handleSceneChange(scene.currentScene)
        sceneHandle = scene.addObserver { [weak self] event in
            guard case .selectionChanged(let scene) = event else { return }
            self?.currentScene = scene
            self?.viewModel?.handleSceneChange(scene)
        }
        playbackHandle = playback.addObserver { [weak self] event in
            self?.viewModel?.handlePlaybackEvent(event)
        }
        token = NotificationCenter.default.addObserver(forName: .bookDBDeleted, object: nil, queue: .main) { [weak self] notification in
            let urls = notification.userInfo?["urls"] as? [URL] ?? []
            Task { @MainActor in self?.viewModel?.handleBookDBDeleted(deletedURLs: urls) }
        }
    }

    func cancel() {
        sceneHandle?.cancel()
        sceneHandle = nil
        playbackHandle?.cancel()
        playbackHandle = nil
        currentScene = nil
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
    }
}
