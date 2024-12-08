import SwiftUI

protocol SuperPlugin {
    var label: String { get }
    var hasPoster: Bool { get }
    var description: String { get }
    var iconName: String { get }

    func addDBView() -> AnyView
    func addPosterView() -> AnyView

    func getDisk() -> (any SuperDisk)?
    
    func onInit() -> Void
    func onAppear() -> Void
    func onDisappear() -> Void
    func onPlay() -> Void
    func onPlayStateUpdate() -> Void
    func onPlayAssetUpdate() -> Void

}

extension SuperPlugin {
    var id: String {
        return self.label
    }

    func addPosterView() -> AnyView {
        return AnyView(EmptyView())
    }

    func getDisk() -> (any SuperDisk)? {
        return nil
    }
}
