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
    nonisolated(unsafe) var enabled: Bool = false
    
    @MainActor
    func addSheetView(storage: StorageLocation?) -> AnyView? {
        guard enabled, storage == nil else { return nil }
        return AnyView(WelcomeView())
    }
}

#Preview("Welcome") {
    RootView {
        WelcomeView()
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
