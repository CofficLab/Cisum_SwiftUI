import Foundation
import OSLog
import SwiftUI

extension Config {
    // MARK: CurrentAudio
    
    @AppStorage("App.CurrentAudio")
    static var currentAudio: URL?
    
    static func setCurrentURL(_ url: URL?) {
        Config.currentAudio = url
    }
    
    // MARK: PlayMode
    
    @AppStorage("App.CurrentMode")
    static var currentMode: String = PlayMode.Order.rawValue
    
    static func setCurrentMode(_ mode: PlayMode) {
        Config.currentMode = mode.rawValue
    }
    
    // MARK: DBViewType
    
    @AppStorage("App.CurentDBViewType")
    static var currentDBViewType: String = DBViewType.List.rawValue
    
    static func setCurrentDBViewType(_ type: DBViewType) {
        Config.currentDBViewType = type.rawValue
    }
    
    // MARK: Scene
    
    @AppStorage("App.Scene")
    static var currentScene: String = AppScene.Music.rawValue
    
    static func getCurrentScene() -> AppScene {
        AppScene.init(rawValue: Config.currentScene)!
    }
    
    static func setCurrentScene(_ scene: AppScene) {
        Config.currentScene = scene.rawValue
    }
}

enum DBViewType: String {
    case Tree
    case List
}
