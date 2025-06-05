import AVKit
import Combine
import Foundation
import MagicCore

import MediaPlayer
import OSLog
import SwiftUI

@MainActor
class AppProvider: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog, SuperThread {
    nonisolated static let emoji = "🐮"

    @Published var showDB: Bool = Config.showDB
    @Published var showSheet: Bool = true
    @Published var isImporting: Bool = false
    @Published var isDropping: Bool = false
    @Published var isResetting: Bool = false
    @Published var rightAlbumVisible = false

    func showDBView() {
        withAnimation {
            self.showDB = true
        }

        Config.setShowDB(true)
    }

    func closeDBView() {
        withAnimation {
            self.showDB = false
        }

        Config.setShowDB(false)
    }

    func toggleDBView() {
        showDB ? self.closeDBView() : self.showDBView()
    }

    func setResetting(_ value: Bool) {
        self.isResetting = value
    }
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}
