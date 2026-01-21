import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

actor DebugPlugin: SuperPlugin {
    let description: String = "调试专用"
    let iconName: String = .iconDebug
    nonisolated(unsafe) var enabled = true
    static var shouldRegister: Bool { false }

    @MainActor
    func addSettingView() -> AnyView? {
        #if DEBUG
            guard enabled else { return nil }
            return AnyView(MagicSettingSection {
                MagicSettingRow(title: "调试", description: "调试相关", icon: .iconDebug) {
                    Logger.logButton().magicSize(.small)
                }
            })
        #else
            return nil
        #endif
    }
}

#Preview("App - Large") {
    ContentView()
        .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
        .inRootView()
        .frame(width: 500, height: 800)
}

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
