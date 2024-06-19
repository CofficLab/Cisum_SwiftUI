import Foundation
import SwiftUI

extension AppConfig {
    // MARK: 当前Audio
    
    @AppStorage("App.CurrentAudio")
    static var currentAudio: URL?
    
    // MARK: 当前播放模式
    
    @AppStorage("App.CurrentMode")
    static var currentMode: String = PlayMode.Order.rawValue
    
    static func setCurrentURL(_ url: URL) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        AppConfig.currentAudio = url
    }
    
    static func setCurrentMode(_ mode: PlayMode) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        AppConfig.currentMode = mode.rawValue
    }
}
