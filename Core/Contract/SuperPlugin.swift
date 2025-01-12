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
    func onCurrentURLChanged(url: URL) async throws
    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws
    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws
    func onStorageLocationChange(storage: StorageLocation?) async throws
    func onLike(asset: URL?, liked: Bool) async throws
}

extension SuperPlugin {
    nonisolated var id: String { self.label }

    nonisolated var isGroup: Bool { false }

    nonisolated func addSheetView(storage: StorageLocation?) -> AnyView? { nil }

    nonisolated func addPosterView() -> AnyView? { nil }

    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] { [] }

    nonisolated func addStateView(currentGroup: SuperPlugin?) -> AnyView? { nil }

    nonisolated func addStatusView() -> AnyView? { nil }

    nonisolated func addRootView() -> AnyView? { nil }

    nonisolated func addDBView(reason: String) -> AnyView? { nil }

    nonisolated func addSettingView() -> AnyView? { nil }

    @MainActor func getDisk() -> URL? { nil }

    func onWillAppear(playMan: PlayManWrapper, currentGroup: SuperPlugin?) {}

    func onInit() {}

    func onCurrentURLChanged(url: URL) { }

    func onDisappear() { }

    func onPlay() { }

    func onPlayModeChange(mode: String, asset: URL?) async throws { }

    func onPause(playMan: MagicPlayMan) async { }

    func onLike(asset: URL?, liked: Bool) async throws { }

    func onPlayStateUpdate() async throws {}

    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws { }

    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws { }

    func onWillAppear(playMan: PlayManWrapper, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async { }

    func onStorageLocationChange(storage: StorageLocation?) async throws {}
}
