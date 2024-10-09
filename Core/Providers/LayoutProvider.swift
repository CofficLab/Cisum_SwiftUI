import Foundation
import MagicKit
import OSLog
import StoreKit
import SwiftData
import SwiftUI

class LayoutProvider: ObservableObject, SuperLog, SuperThread {
    let emoji = "🧩"

    @Published var current: any SuperLayout

    var items: [any SuperLayout] = [
        AudioApp(),
//        VideoApp(),
        BookApp(),
    ]

    var posters: [any View] {
        self.items.map { $0.poster }
    }

    var layout: AnyView {
        AnyView(self.current.rootView)
    }

    init() {
        let verbose = true
        if verbose {
            os_log("\(Logger.initLog) LayoutProvider")
        }
        
        let currentLayoutId = Config.getLayoutId()

        if let c = items.first(where: { $0.id == currentLayoutId }) {
            os_log("  ➡️ Set Current Layout: \(c.id)")
            self.current = c
        } else {
            os_log("  ➡️ Set Default Layout: \(self.items.first!.id)")
            self.current = self.items.first!
        }
    }

    func setLayout(_ l: any SuperLayout) {
        if l.id == self.current.id {
            return
        }

        os_log("\(self.t)setLayout -> \(l.title)")

        self.current = l

        Config.storeLayout(self.current)
    }
}

// MARK: Config

extension Config {
    static func storeLayout(_ l: any SuperLayout) {
        let id = l.id
        
        UserDefaults.standard.set(id, forKey: "currentLayoutID")

        // Synchronize with CloudKit
        NSUbiquitousKeyValueStore.default.set(id, forKey: "currentLayoutID")
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func getLayoutId() -> String {
        // First, try to get the layout ID from UserDefaults
        if let id = UserDefaults.standard.string(forKey: "currentLayoutID") {
            return id
        }
        
        // If not found in UserDefaults, try to get from iCloud
        if let id = NSUbiquitousKeyValueStore.default.string(forKey: "currentLayoutID") {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(id, forKey: "currentLayoutID")
            return id
        }
        
        return ""
    }
}
