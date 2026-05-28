import MagicKit
import OSLog
import PluginAudioSettings
import SwiftUI

/**
 * 音频设置插件，提供音频设置面板。
 */
actor AudioSettingsPlugin: SuperPlugin, SuperLog {
    static let shared = AudioSettingsPlugin()
    nonisolated static let emoji = AudioSettingsPluginInfo.emoji
    static var shouldRegister: Bool { true }
    private static let verbose = false
    /// 注册顺序设为 10，在其他音频插件之后执行
    static var order: Int { AudioSettingsPluginInfo.order }
    nonisolated var title: String { AudioSettingsPluginInfo.title }
    nonisolated var description: String { AudioSettingsPluginInfo.description }
    let iconName = AudioSettingsPluginInfo.iconName
    

    @MainActor
    func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)⚙️ 加载音频设置视图")
        }

        return AnyView(AudioSettingsPluginView())
    }
}

private struct AudioSettingsPluginView: View {
    @State private var refreshToken = 0

    var body: some View {
        AudioSettingsView(refreshToken: refreshToken) {
            AudioPlugin.getAudioDisk()
        }
        .onStorageLocationChanged {
            refreshToken += 1
        }
    }
}
