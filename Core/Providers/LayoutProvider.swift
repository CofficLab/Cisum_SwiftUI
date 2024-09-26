import Foundation
import OSLog
import StoreKit
import SwiftData
import SwiftUI
import MagicKit

class LayoutProvider: ObservableObject, SuperLog, SuperThread {
    let emoji = "🧩"
    
    @Published var current: any SuperLayout
    
    var items: [any SuperLayout] = [
        AudioApp(),
//        VideoApp(),
//        BookApp()
    ]
    
    var posters: [any View] {
        self.items.map { $0.poster }
    }
    
    var layout: AnyView {
        AnyView(self.current.layout)
    }

    init() {
        let verbose = false
        if verbose {
            os_log("\(Logger.initLog) PluginProvider")
        }
        
        self.current = self.items.first!
    }

    func setLayout(_ l: any SuperLayout) {
        os_log("\(self.t)setLayout -> \(l.title)")
        self.current = l
    }
}
