import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import ProviderScene
import SwiftUI

public typealias AudioControlAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioControlFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioControlLastAssetProvider = @MainActor () async throws -> URL?

enum AudioControlPlaybackRequestPolicy {
    static func shouldApplyNavigationResult(
        requestedAsset: URL,
        currentAsset: URL?,
        isSceneActive: Bool,
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        currentGeneration == requestGeneration
            && isSceneActive
            && representsSameFile(requestedAsset, currentAsset)
    }

    static func shouldReportNavigationFailure(
        requestedAsset: URL,
        currentAsset: URL?,
        isSceneActive: Bool,
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        shouldApplyNavigationResult(
            requestedAsset: requestedAsset,
            currentAsset: currentAsset,
            isSceneActive: isSceneActive,
            currentGeneration: currentGeneration,
            requestGeneration: requestGeneration
        )
    }

    static func currentAssetAffectedByDeletion(currentAsset: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentAsset else { return false }
        return deletedURLs.contains { deletedURL in
            representsSameFile(currentAsset, deletedURL)
        }
    }

    static func shouldApplyDeletionRecovery(
        currentAsset: URL?,
        deletedURLs: [URL],
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        currentGeneration == requestGeneration
            && currentAssetAffectedByDeletion(currentAsset: currentAsset, deletedURLs: deletedURLs)
    }

    static func shouldResetForStorageLocationChange(isSceneActive: Bool) -> Bool {
        isSceneActive
    }

    static func shouldApplyStorageReset(
        currentGeneration: Int,
        requestGeneration: Int,
        isSceneActive: Bool
    ) -> Bool {
        currentGeneration == requestGeneration && isSceneActive
    }

    static func generationAfterDeactivation(_ generation: Int) -> Int {
        generation + 1
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return lhs.isSameFileLocation(as: rhs)
        default:
            return false
        }
    }

    private static func representsSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.isSameFileLocation(as: rhs)
    }
}

public struct AudioControlRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan
    @ObservedObject private var viewModel: AudioControlViewModel

    private let content: Content
    private let targetScene: AppScene
    private let scene: (any SceneProviding)?

    init(
        targetScene: AppScene,
        scene: (any SceneProviding)?,
        viewModel: AudioControlViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.targetScene = targetScene
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear {
                viewModel.bind(playMan: man)
                viewModel.handleSceneChange(scene?.currentScene)
            }
            .onDisappear {
                viewModel.handleSceneChange(nil)
            }
            .onChange(of: scene?.currentScene) { _, newScene in
                viewModel.handleSceneChange(newScene)
            }
    }
}
