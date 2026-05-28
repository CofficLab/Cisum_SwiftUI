import Foundation
import MagicKit
import OSLog
import SwiftUI

actor StorePlugin: SuperPlugin {
    static let shared = StorePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 80 }

    nonisolated var title: String { String(localized: "Store", table: "Store") }
    nonisolated var description: String { String(localized: "In-App purchases and subscriptions", table: "Store") }
    let iconName = "cart"

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(StoreSetting())
    }
}

#Preview("App - Large") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
