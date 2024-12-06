import Foundation
import OSLog
import MagicKit
import SwiftUI

class PlayPlugin: SuperPlugin, SuperLog {
    let emoji = "🥣"
    
    var label: String = ""

    func addDBView() -> AnyView? {
        os_log("\(self.t)AddDBView")
        
        return AnyView {
            Text("Hi")
        }
    }
    
    func onPlay() {
        os_log("\(self.t)OnPlay")
    }
    
    func onPlayStateUpdate() {
        os_log("\(self.t)OnPlayStateUpdate")
    }

    func onPlayAssetUpdate() {
        os_log("\(self.t)OnPlayAssetUpdate")
    }

    func onInit() {
        os_log("\(self.t)OnInit")
    }

    func onAppear() {
        os_log("\(self.t)OnAppear")
    }

    func onDisappear() {
        os_log("\(self.t)OnDisappear")
    }
}
