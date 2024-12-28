import OSLog
import SwiftUI

protocol SuperPlugin {
    var id: String { get }
    var label: String { get }
    var hasPoster: Bool { get }
    var description: String { get }
    var iconName: String { get }
    var isGroup: Bool { get }

    func addRootView() -> AnyView?
    func addSheetView(storage: StorageLocation?) -> AnyView?
    func addDBView(reason: String) -> AnyView?
    func addPosterView() -> AnyView
    func addStateView(currentGroup: SuperPlugin?) -> AnyView?
    func addSettingView() -> AnyView?
    func addStatusView() -> AnyView?
    func addToolBarButtons() -> [(id: String, view: AnyView)]

    func getDisk() -> (any SuperStorage)?

    func onWillAppear(playMan: PlayMan, currentGroup: SuperPlugin?, storage: StorageLocation?) async -> Void
    func onDisappear() -> Void
    func onPlay() -> Void
    func onPause(playMan: PlayMan) async -> Void
    func onPlayStateUpdate() async throws -> Void
    func onPlayModeChange(mode: PlayMode, asset: PlayAsset?) async throws -> Void
    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) async throws -> Void
    func onPlayNext(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws -> Void
    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws -> Void
}

extension SuperPlugin {
    var id: String {
        return self.label
    }

    var isGroup: Bool {
        return false
    }
    
    func addSheetView(storage: StorageLocation?) -> AnyView? {
        return nil
    }

    func addPosterView() -> AnyView {
        return AnyView(EmptyView())
    }

    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return []
    }

    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        return nil
    }

    func addStatusView() -> AnyView? {
        return nil
    }

    func addRootView() -> AnyView? {
        return nil
    }

    func addDBView(reason: String) -> AnyView? {
        return nil
    }

    func addSettingView() -> AnyView? {
        return nil
    }

    func getDisk() -> (any SuperStorage)? {
        return nil
    }

    func onWillAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
    }

    func onInit() {
    }

    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) {
    }

    func onDisappear() {
    }

    func onPlay() {
    }

    func onPlayModeChange(mode: PlayMode, asset: PlayAsset?) async throws {
    }

    func onPause(playMan: PlayMan) async {
    }

    func onPlayStateUpdate() async throws {
    }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
    }
    
    func onWillAppear(playMan: PlayMan, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async {
        
    }
}
