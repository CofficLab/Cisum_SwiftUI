import Foundation
import MagicKit
import OSLog
import StoreKit
import SwiftData
import SwiftUI

class PluginProvider: ObservableObject, SuperLog, SuperThread {
    let emoji = "🧩"

    @Published var plugins: [SuperPlugin] = []

    init() {
        os_log("\(Logger.initLog) PluginProvider")
    }

    func append(_ plugin: SuperPlugin) {
        self.plugins.append(plugin)
    }
}
