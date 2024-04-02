import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class WindowManager: NSObject, ObservableObject {
    @Published var width: CGFloat = 0
    @Published var sidebarWidth: CGFloat = 0
    
    var contentWidth: CGFloat {
        width - sidebarWidth
    }
}
