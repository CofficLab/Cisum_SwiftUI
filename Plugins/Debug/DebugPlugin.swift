import Foundation
import OSLog
import MagicKit
import SwiftUI

class DebugPlugin: SuperPlugin, SuperLog {
    var hasPoster: Bool = false
    let description: String = "作为播放器，只关注文件，文件夹将被忽略"
    static let emoji = "🥣"
    var iconName: String = "play"
    var label: String = ""

    func addDBView(reason: String) -> AnyView {
        os_log("\(self.t)AddDBView")
        
        return AnyView(Text("Hi"))
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

    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
        os_log("\(self.t)OnAppear, currentGroup: \(currentGroup?.id ?? "nil")")
    }

    func onDisappear() {
        os_log("\(self.t)OnDisappear")
    }
}
