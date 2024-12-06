import SwiftUI

protocol SuperPlugin {
    var label: String { get }

    func addDBView() -> AnyView?
    
    func onInit() -> Void
    func onAppear() -> Void
    func onDisappear() -> Void
    func onPlay() -> Void
    func onPlayStateUpdate() -> Void
    func onPlayAssetUpdate() -> Void
}
