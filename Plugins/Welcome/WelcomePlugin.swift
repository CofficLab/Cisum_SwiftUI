import Foundation
import MagicCore
import OSLog
import SwiftUI

actor WelcomePlugin: SuperPlugin, SuperLog {
    static let emoji = "👏"

    let label = "Welcome"
    let hasPoster = false
    let description = "欢迎界面"
    let iconName = "music.note"
    nonisolated(unsafe) var enabled = true
    
    @MainActor
    func addLaunchView() -> AnyView? {
        guard enabled else { return nil }
        return AnyView(WelcomeView())
    }
}

#Preview("Welcome") {
    RootView {
        WelcomeView()
    }
    .frame(height: 800)
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
