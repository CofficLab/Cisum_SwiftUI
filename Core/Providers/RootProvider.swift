import Foundation
import MagicKit
import OSLog
import StoreKit
import SwiftData
import SwiftUI

class RootProvider: ObservableObject, SuperLog, SuperThread {
    static let keyOfCurrentLayoutID = "currentLayoutID"

    let emoji = "🧩"

    @Published var current: any SuperRoot

    var items: [any SuperRoot] = [
        AudioRoot(),
//        VideoApp(),
        BookRoot(),
    ]

    var posters: [any View] {
        self.items.map { $0.poster }
    }

    var layout: AnyView {
        AnyView(self.current)
    }

    init() {
        let verbose = true
        if verbose {
            os_log("\(Logger.initLog) RootProvider")
        }

        let currentLayoutId = Self.getLayoutId()

        if let c = items.first(where: { $0.id == currentLayoutId }) {
            os_log("  ➡️ Set Current Root: \(c.id)")
            self.current = c
        } else {
            os_log("  ➡️ Set Default Root: \(self.items.first!.id)")
            self.current = self.items.first!
        }
    }

    func setLayout(_ l: any SuperRoot) {
        if l.id == self.current.id {
            return
        }

        os_log("\(self.t)SetRoot -> \(l.title)")

        self.current = l

        Self.storeLayout(self.current)
    }

    static func storeLayout(_ l: any SuperRoot) {
        let id = l.id

        UserDefaults.standard.set(id, forKey: keyOfCurrentLayoutID)

        // Synchronize with CloudKit
        NSUbiquitousKeyValueStore.default.set(id, forKey: keyOfCurrentLayoutID)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func getLayoutId() -> String {
        // First, try to get the layout ID from UserDefaults
        if let id = UserDefaults.standard.string(forKey: keyOfCurrentLayoutID) {
            return id
        }

        // If not found in UserDefaults, try to get from iCloud
        if let id = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentLayoutID) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(id, forKey: keyOfCurrentLayoutID)
            return id
        }

        return ""
    }
}
