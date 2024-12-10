import OSLog
import SwiftUI

protocol SuperPlugin {
    var id: String { get }
    var label: String { get }
    var hasPoster: Bool { get }
    var description: String { get }
    var iconName: String { get }
    var isGroup: Bool { get }

    func addDBView() -> AnyView
    func addPosterView() -> AnyView
    func addStateView() -> AnyView?
    func addToolBarButtons() -> [(id: String, view: AnyView)]

    func getDisk() -> (any SuperDisk)?

    func onInit() -> Void
    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) -> Void
    func onDisappear() -> Void
    func onPlay() -> Void
    func onPause(playMan: PlayMan) -> Void
    func onPlayStateUpdate() async throws -> Void
    func onPlayAssetUpdate(asset: PlayAsset?) async throws -> Void
    func onPlayNext(playMan: PlayMan, current: PlayAsset?, verbose: Bool) async throws -> Void
    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, verbose: Bool) async throws -> Void
}

extension SuperPlugin {
    var id: String {
        return self.label
    }
    
    var isGroup: Bool {
        return false
    }
    
    func addPosterView() -> AnyView {
        return AnyView(EmptyView())
    }
    
    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return []
    }

    func addStateView() -> AnyView? {
        return nil
    }
    
    func getDisk() -> (any SuperDisk)? {
        return nil
    }
    
    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
        os_log("🐷 %{public}s::OnAppear, currentGroup: %{public}s", log: .default, type: .debug, String(describing: type(of: self)), currentGroup?.id ?? "nil")
    }
    
    func onInit() {
        os_log("🐷 %{public}s::OnInit", log: .default, type: .debug, String(describing: type(of: self)))
    }
    
    func onPlayAssetUpdate(asset: PlayAsset?) {
        os_log("🐷 %{public}s::OnPlayAssetUpdate", log: .default, type: .debug, String(describing: type(of: self)))
    }
    
    func onDisappear() {
        os_log("🐷 %{public}s::OnDisappear", log: .default, type: .debug, String(describing: type(of: self)))
    }
    
    func onPlay() {
        os_log("🐷 %{public}s::OnPlay", log: .default, type: .debug, String(describing: type(of: self)))
    }
    
    func onPause(playMan: PlayMan) {
        Task {
            let timeDisplay = await playMan.currentTimeDisplay
            os_log("🐷 %{public}s::OnPause, current time: %{public}s", log: .default, type: .debug, String(describing: type(of: self)), timeDisplay)
        }
    }
    
    func onPlayStateUpdate() async throws -> Void {
        os_log("🐷 %{public}s::OnPlayStateUpdate", log: .default, type: .debug, String(describing: type(of: self)))
    }
    
    func onPlayNext(playMan: PlayMan, current: PlayAsset?, verbose: Bool) async throws -> Void {
        os_log("🐷 %{public}s::OnPlayNext while current is %{public}s", log: .default, type: .debug, String(describing: type(of: self)), current?.title ?? "nil")
    }
    
    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, verbose: Bool) async throws -> Void {
        os_log("🐷 %{public}s::OnPlayPrev while current is %{public}s", log: .default, type: .debug, String(describing: type(of: self)), current?.title ?? "nil")
    }
}
