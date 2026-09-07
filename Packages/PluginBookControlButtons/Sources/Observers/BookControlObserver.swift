import Foundation
import OSLog
import ProviderPlayback
import ProviderScene
import MagicKit

/// 书籍控制的数据库与存储重置观察者（迁移 Phase 5）。
///
/// 订阅 `.bookDBDeleted` / `.bookDBSynced` / `.bookDBUpdated` /
/// 存储重置通知，转发到 `BookControlViewModel`；取代原
/// `BookControlRootView` 的四个 `.onReceive` 直接订阅。
@MainActor
final class BookControlObserver: SuperLog {
    nonisolated static let verbose = true

    private weak var viewModel: BookControlViewModel?
    private var tokens: [NSObjectProtocol] = []
    private var sceneHandle: (any SceneProvidingObserverHandle)?
    private var playbackHandle: (any PlaybackProvidingObserverHandle)?

    init(
        scene: any SceneProviding,
        playback: any PlaybackProviding,
        viewModel: BookControlViewModel
    ) {
        self.viewModel = viewModel
        if Self.verbose { os_log("\(Self.t)👀 BookControlObserver 初始化") }
        viewModel.handleSceneChange(scene.currentScene)
        sceneHandle = scene.addObserver { [weak self] event in
            guard case .selectionChanged(let scene) = event else { return }
            self?.viewModel?.handleSceneChange(scene)
        }
        playbackHandle = playback.addObserver { [weak self] event in
            guard let self else { return }
            switch event {
            case .stateChanged(let state):
                self.viewModel?.applyStateChanged(state)
            case .playModeChanged(let mode):
                self.viewModel?.applyPlayModeChanged(mode)
            case .previousRequested(let asset):
                self.viewModel?.handlePreviousRequested(asset)
            case .nextRequested(let asset):
                self.viewModel?.handleNextRequested(asset)
            default:
                break
            }
        }
        let center = NotificationCenter.default

        tokens.append(center.addObserver(forName: .bookDBDeleted, object: nil, queue: .main) { [weak self] notification in
            let urls = notification.userInfo?["urls"] as? [URL] ?? []
            Task { @MainActor in self?.viewModel?.handleBookDBDeleted(deletedURLs: urls) }
        })
        tokens.append(center.addObserver(forName: .bookDBSynced, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBRefreshed() }
        })
        tokens.append(center.addObserver(forName: .bookDBUpdated, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleBookDBRefreshed() }
        })
        tokens.append(center.addObserver(forName: Notification.Name("storageLocationDidReset"), object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.viewModel?.handleStorageLocationDidReset() }
        })
    }

    func cancel() {
        if Self.verbose { os_log("\(Self.t)🧹 BookControlObserver 取消") }
        sceneHandle?.cancel()
        sceneHandle = nil
        playbackHandle?.cancel()
        playbackHandle = nil
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
}
