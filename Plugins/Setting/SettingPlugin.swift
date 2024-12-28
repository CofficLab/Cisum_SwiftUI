import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

class SettingPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let dirName = "audios"
    let label: String = "Setting"
    var hasPoster: Bool = true
    let description: String = "设置"
    var iconName: String = "music.note"
    var isGroup: Bool = false

    init() {
        os_log("\(self.i)")
    }

    func addDBView(reason: String) -> AnyView? {
        nil
    }

    func addPosterView() -> AnyView {
        AnyView(EmptyView())
    }

    func addSettingView() -> AnyView? {
        AnyView(SettingPluginView())
    }

    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        nil
    }

    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        []
    }

    func onPause(playMan: PlayMan) {
        Task { @MainActor in
            AudioPlugin.storeCurrentTime(playMan.currentTime)
        }
    }

    func onPlay() {
    }

    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) async throws {
    }

    func getDisk() -> (any SuperStorage)? {
        nil
    }

    func onPlayModeChange(mode: PlayMode, asset: PlayAsset?) async throws {
    }

    func onWillAppear(playMan: PlayMan, currentGroup: SuperPlugin?, storage: StorageLocation?) async {
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws { }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws { }
}
