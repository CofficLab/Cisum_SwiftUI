import MagicKit
import OSLog
import SwiftUI

/**
 * 音频设置插件，提供音频设置面板。
 */
actor AudioSettingsPlugin: SuperPlugin, SuperLog {
    static let shared = AudioSettingsPlugin()
    nonisolated static let emoji = "🛠️"
    static var shouldRegister: Bool { true }
    private static let verbose = false
    /// 注册顺序设为 10，在其他音频插件之后执行
    static var order: Int { 10 }
    let title = "音频设置"
    let description = "音频插件的设置入口"
    let iconName = "gearshape"
    

    @MainActor
    func addSettingView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)⚙️ 加载音频设置视图")
        }

        return AnyView(AudioSettings())
    }
}

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
