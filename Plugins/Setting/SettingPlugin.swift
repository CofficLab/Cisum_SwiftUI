import Foundation
import MagicKit
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

    func addRootView() -> AnyView? {
        AnyView(SettingRootView())
    }

    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        nil
    }

    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        []
    }

    func onInit(storage: StorageLocation?) {
        os_log("\(self.t)🛫🛫🛫 OnInit")
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

    func getDisk() -> (any SuperDisk)? {
        nil
    }

    func onPlayModeChange(mode: PlayMode, asset: PlayAsset?) async throws {
    }

    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) async {
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws { }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws { }
}
