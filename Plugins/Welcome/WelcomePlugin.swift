import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

actor WelcomePlugin: SuperPlugin, SuperLog {
    static let emoji = "👏"

    let label = "Welcome"
    let hasPoster = false
    let description = "设置"
    let iconName = "music.note"
    
    @MainActor
    func addSheetView(storage: StorageLocation?) -> AnyView? {
        guard storage == nil else { return nil}
        
        return AnyView(WelcomeView())
    }
}
