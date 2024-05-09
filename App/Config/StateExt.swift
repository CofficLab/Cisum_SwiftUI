import Foundation
import SwiftUI

// MARK: APP状态

extension AppConfig {
    @AppStorage("App.CurrentAudio")
    static var currentAudio: URL?
    
    @AppStorage("App.CurrentMode")
    static var currentMode: String = PlayMode.Order.rawValue
    
    static func setCurrentAudio(_ audio: Audio) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        AppConfig.currentAudio = audio.url
    }
    
    static func setCurrentMode(_ mode: PlayMode) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        AppConfig.currentMode = mode.rawValue
    }
}
