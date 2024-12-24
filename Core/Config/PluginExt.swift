import SwiftUI

extension Config {
    static func getPlugins() -> [SuperPlugin] {
        return [
            SettingPlugin(),
            // DebugPlugin(),
            AudioPlugin(),
//            BookPlugin()
            CopyPlugin(),
        ]
    }
}
