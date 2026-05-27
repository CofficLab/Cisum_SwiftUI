import Foundation
import MagicKit
import OSLog
import SwiftUI

actor WelcomePlugin: SuperPlugin, SuperLog {
    static let shared = WelcomePlugin()
    static let emoji = "👏"
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 -100，最先执行
    static var order: Int { -100 }

    let title = "欢迎"
    let description = "欢迎界面"
    let iconName = "hand.wave"

    @MainActor
    func addGuideView() -> AnyView? {
        guard Config.getStorageLocation() == nil else {
            return nil
        }

        return AnyView(WelcomeView())
    }
}

#Preview("WelcomePlugin") {
    RootView {
        WelcomeView()
    }
    .frame(height: 800)
}

#Preview("WelcomePlugin - Dark") {
    RootView {
        WelcomeView()
    }
    .frame(height: 800)
    .preferredColorScheme(.dark)
}

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
