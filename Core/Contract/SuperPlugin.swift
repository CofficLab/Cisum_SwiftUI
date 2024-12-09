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
    func addToolBarButtons() -> [(id: String, view: AnyView)]

    func getDisk() -> (any SuperDisk)?

    func onInit() -> Void
    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) -> Void
    func onDisappear() -> Void
    func onPlay() -> Void
    func onPause(playMan: PlayMan) -> Void
    func onPlayStateUpdate() -> Void
    func onPlayAssetUpdate(asset: PlayAsset?) -> Void
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
        os_log("🐷 %{public}s::OnPause, current time: %{public}s", log: .default, type: .debug, String(describing: type(of: self)), playMan.currentTimeDisplay)
    }

    func onPlayStateUpdate() {
        os_log("🐷 %{public}s::OnPlayStateUpdate", log: .default, type: .debug, String(describing: type(of: self)))
    }
}
