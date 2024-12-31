import Foundation
import OSLog
import SwiftUI
import MagicKit

protocol PlayAssetDelegate {
    func onLikeChange(like: Bool, asset: PlayAsset) async throws
    func delete() async throws
    func toggleLike() async throws
}

extension PlayAssetDelegate {
    func delete() async throws {
        throw PlayAssetError.notImplemented
    }

    func toggleLike() async throws {
        throw PlayAssetError.notImplemented
    }

    func onLikeChange(like: Bool, asset: PlayAsset) async throws {
        os_log("🍋🍋🍋 OnLikeChange, like: \(like), asset: \(asset.title)")
    }
}
