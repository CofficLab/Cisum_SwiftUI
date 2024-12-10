import Foundation
import OSLog

protocol PlayManDelegate {
    func onPlayPrev(current: PlayAsset?) -> Void
    func onPlayNext(current: PlayAsset?) async -> Void
}

extension PlayManDelegate {
    func onPlayPrev(current: PlayAsset?) -> Void {
        os_log("🐷 %{public}s::OnPlayPrev while current is %{public}s", log: .default, type: .debug, String(describing: type(of: self)), current?.title ?? "nil")
    }

    func onPlayNext(current: PlayAsset?) async -> Void {
        os_log("🐷 %{public}s::OnPlayNext while current is %{public}s", log: .default, type: .debug, String(describing: type(of: self)), current?.title ?? "nil")
    }
}
