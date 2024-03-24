import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class PlayListManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var current: PlayList = PlayList(title: "所有")
    var items: [PlayList] = [
        PlayList(title: "所有"),
        PlayList(title: "喜欢"),
        PlayList(title: "经常"),
        PlayList(title: "回收站")
    ]
}
