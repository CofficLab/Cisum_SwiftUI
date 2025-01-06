import Foundation
import OSLog
import MagicKit
import MagicUI
import SwiftUI

class DebugPlugin: SuperPlugin, SuperLog {
    static let emoji = "🥣"
    
    let hasPoster = false
    let description = "作为播放器，只关注文件，文件夹将被忽略"
    let iconName = "play"
    let label = "debug"
    let id = "Debug"
}
