import MagicPlayMan
import OSLog
import SwiftUI

protocol SuperPlugin: Actor {
    nonisolated var id: String { get }
    nonisolated var label: String { get }
    nonisolated var hasPoster: Bool { get }
    nonisolated var description: String { get }
    nonisolated var iconName: String { get }
    nonisolated var isGroup: Bool { get }

    @MainActor func addRootView() -> AnyView?
    @MainActor func addSheetView(storage: StorageLocation?) -> AnyView?
    @MainActor func addDBView(reason: String) -> AnyView?
    @MainActor func addPosterView() -> AnyView?
    @MainActor func addStateView(currentGroup: SuperPlugin?) -> AnyView?
    @MainActor func addSettingView() -> AnyView?
    @MainActor func addStatusView() -> AnyView?
    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)]

    @MainActor func getDisk() -> URL?

    func onWillAppear(playMan: PlayManWrapper, currentGroup: SuperPlugin?, storage: StorageLocation?) async throws
    func onDisappear()
    func onPlay()
    func onPause(playMan: MagicPlayMan) async
    func onPlayStateUpdate() async throws
    func onPlayModeChange(mode: String, asset: URL?) async throws
    func onPlayAssetUpdate(asset: MagicAsset?, currentGroup: SuperPlugin?) async throws
    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws
    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws
    func onStorageLocationChange(storage: StorageLocation?) async throws
    func onLike(asset: URL?, liked: Bool) async throws
}

extension SuperPlugin {
    nonisolated var id: String {
        return self.label
    }

    nonisolated var isGroup: Bool {
        return false
    }

    nonisolated func addSheetView(storage: StorageLocation?) -> AnyView? { nil }

    nonisolated func addPosterView() -> AnyView? { nil }

    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return []
    }

    nonisolated func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        return nil
    }

    nonisolated func addStatusView() -> AnyView? {
        return nil
    }

    nonisolated func addRootView() -> AnyView? {
        return nil
    }

    nonisolated func addDBView(reason: String) -> AnyView? {
        return nil
    }

    nonisolated func addSettingView() -> AnyView? {
        return nil
    }

    @MainActor func getDisk() -> URL? {
        return nil
    }

    func onWillAppear(playMan: PlayManWrapper, currentGroup: SuperPlugin?) {}

    func onInit() {
    }

    func onPlayAssetUpdate(asset: MagicAsset?, currentGroup: SuperPlugin?) {
    }

    func onDisappear() {
    }

    func onPlay() {
    }

    func onPlayModeChange(mode: String, asset: URL?) async throws { }

    func onPause(playMan: MagicPlayMan) async { }

    func onLike(asset: URL?, liked: Bool) async throws { }

    func onPlayStateUpdate() async throws {}

    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
    }

    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
    }

    func onWillAppear(playMan: PlayManWrapper, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async {
    }

    func onStorageLocationChange(storage: StorageLocation?) async throws {}
}
