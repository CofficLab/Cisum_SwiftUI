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

    nonisolated var title: String { String(localized: "Welcome", table: "Welcome") }
    nonisolated var description: String { String(localized: "Welcome screen", table: "Welcome") }
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
