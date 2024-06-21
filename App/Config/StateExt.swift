import Foundation
import OSLog
import SwiftUI

extension Config {
    // MARK: 当前Audio
    
    @AppStorage("App.CurrentAudio")
    static var currentAudio: URL?
    
    static func setCurrentURL(_ url: URL?) {
        Config.currentAudio = url
    }
    
    // MARK: 当前播放模式
    
    @AppStorage("App.CurrentMode")
    static var currentMode: String = PlayMode.Order.rawValue
    
    static func setCurrentMode(_ mode: PlayMode) {
        Config.currentMode = mode.rawValue
    }
    
    // MARK: 当前数据库视图
    
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
