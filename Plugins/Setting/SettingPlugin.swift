import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

actor SettingPlugin: SuperPlugin, @preconcurrency SuperLog {
    static let emoji = "⚙️"

    let dirName = "audios"
    let label: String = "Setting"
    let hasPoster: Bool = true
    let description: String = "设置"
    let iconName: String = "music.note"
    let isGroup: Bool = false

    @MainActor
    func addDBView(reason: String) -> AnyView? {
        nil
    }

    @MainActor
    func addPosterView() -> AnyView {
        AnyView(EmptyView())
    }

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(SettingPluginView())
    }

    func onPause(playMan: PlayMan) {
        AudioPlugin.storeCurrentTime(playMan.currentTime)
    }
}
