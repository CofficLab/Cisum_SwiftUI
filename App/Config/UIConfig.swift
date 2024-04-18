import Foundation
import SwiftUI
import SwiftData
import OSLog

enum UIConfig {
    static var isDesktop: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
    
    static var isNotDesktop: Bool { !isDesktop }
    
    @AppStorage("UI.ShowDB")
    static var showDB: Bool = false
    
    static func setShowDB(_ value: Bool) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        UIConfig.showDB = value
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
