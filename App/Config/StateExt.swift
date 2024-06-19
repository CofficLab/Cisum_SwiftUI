import Foundation
import OSLog
import SwiftUI

extension Config {
    // MARK: 当前Audio
    
    @AppStorage("App.CurrentAudio")
    static var currentAudio: URL?
    
    // MARK: 当前播放模式
    
    @AppStorage("App.CurrentMode")
    static var currentMode: String = PlayMode.Order.rawValue
    
    static func setCurrentURL(_ url: URL?) {
        Config.currentAudio = url
    }
    
    static func setCurrentMode(_ mode: PlayMode) {
        Config.currentMode = mode.rawValue
    }
}
