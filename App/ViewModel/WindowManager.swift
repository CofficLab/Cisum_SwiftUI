import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

enum Navigations {
    case Database
}

class WindowManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var width: CGFloat = 0
    @Published var sidebarWidth: CGFloat = 0
    @Published var navigation: Navigations = .Database
    
    var contentWidth: CGFloat {
        width - sidebarWidth
    }
}
