import Foundation
import MagicKit
import OSLog
import SwiftUI

actor WelcomePlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "👏"
    static let verbose = true
    private static var enabled: Bool { true }

    let label = "Welcome"
    let description = "欢迎界面"
    let iconName = "music.note"
    nonisolated(unsafe) var enabled = true
    
    @MainActor
    func addLaunchView() -> AnyView? {
        guard Config.getStorageLocation() == nil else {
            if Self.verbose {
                os_log("\(self.t)🔍 StorageLocation is not nil")
            }
            return nil
        }

        if Self.verbose {
            os_log("\(self.t)🔍 StorageLocation is nil, show WelcomeView")
        }
        
        return AnyView(WelcomeView())
    }
}

// MARK: - PluginRegistrant
extension WelcomePlugin {
    @objc static func register() {
        guard Self.enabled else {
            return 
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀 Register")
            }

            await PluginRegistry.shared.register(id: "Welcome", order: -100) {
                WelcomePlugin()
            }
        }
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

#if os(macOS)
#Preview("App - Large") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    ContentView()
    .inRootView()
}
#endif
