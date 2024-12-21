import SwiftUI

extension Config {
    static func getPlugins() -> [SuperPlugin] {
        return [
            // DebugPlugin(),
            AudioPlugin(),
//            BookPlugin()
        ]
    }
}
