import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

class WelcomePlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let label: String = "Welcome"
    var hasPoster: Bool = true
    let description: String = "设置"
    var iconName: String = "music.note"

    init() {
        os_log("\(self.i)")
    }
    
    func addSheetView(storage: StorageLocation?) -> AnyView? {
        guard storage == nil else { return nil}
        
        return AnyView(WelcomeView())
    }
}
