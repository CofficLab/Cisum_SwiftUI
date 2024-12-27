import Foundation
import OSLog
import SwiftUI

extension Config {
    // MARK: PlayMode
    
//    @AppStorage("App.CurrentMode")
//    static var currentMode: String = PlayMode.Order.rawValue
//    
//    static func setCurrentMode(_ mode: PlayMode) {
//        Config.currentMode = mode.rawValue
//    }
    
    // MARK: DBViewType
    
    @AppStorage("App.CurentDBViewType")
    static var currentDBViewType: String = DBViewType.List.rawValue
    
    static func setCurrentDBViewType(_ type: DBViewType) {
        Config.currentDBViewType = type.rawValue
    }
}

enum DBViewType: String {
    case Tree
    case List
}
