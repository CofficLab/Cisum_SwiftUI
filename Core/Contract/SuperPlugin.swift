import OSLog
import SwiftUI

protocol SuperPlugin: MagicSuperPlugin {
    @MainActor func addLaunchView() -> AnyView?
    @MainActor func addSheetView(storage: StorageLocation?) -> AnyView?
    @MainActor func addDBView(reason: String) -> AnyView?
    @MainActor func addStateView(currentGroup: SuperPlugin?) -> AnyView?
    @MainActor func addPosterView() -> AnyView?
    @MainActor func addSettingView() -> AnyView?
    @MainActor func addStatusView() -> AnyView?
    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)]
    @MainActor func getDisk() -> URL?

    func onDisappear()
    func onPlay()
    func onPlayStateUpdate() async throws
    func onPlayModeChange(mode: String, asset: URL?) async throws
    func onCurrentURLChanged(url: URL) async throws
    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws
    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws
    func onStorageLocationChange(storage: StorageLocation?) async throws
    func onLike(asset: URL?, liked: Bool) async throws
}

extension SuperPlugin {
    nonisolated func addLaunchView() -> AnyView? { nil }
    nonisolated func addSheetView(storage: StorageLocation?) -> AnyView? { nil }

    nonisolated func addStateView(currentGroup: SuperPlugin?) -> AnyView? { nil }

    nonisolated func addDBView(reason: String) -> AnyView? { nil }

    nonisolated func addPosterView() -> AnyView? { nil }

    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] { [] }

    nonisolated func addStatusView() -> AnyView? { nil }
    
    nonisolated func addSettingView() -> AnyView? { nil }

    @MainActor func getDisk() -> URL? { nil }

    func onWillAppear(playMan: PlayManWrapper, currentGroup: SuperPlugin?) {}

    func onInit() {}

    func onCurrentURLChanged(url: URL) { }

    func onDisappear() { }

    func onPlay() { }

    func onPlayModeChange(mode: String, asset: URL?) async throws { }

    func onLike(asset: URL?, liked: Bool) async throws { }

    func onPlayStateUpdate() async throws {}

    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws { }

    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws { }

    func onStorageLocationChange(storage: StorageLocation?) async throws {}
}
