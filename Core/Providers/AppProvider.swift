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

    // 使用 UIRepo 来管理 UI 相关的数据
    private let uiRepo = UIRepo()
    
    @Published var showDB: Bool
    @Published var showSheet: Bool = true
    @Published var isImporting: Bool = false
    @Published var isDropping: Bool = false
    @Published var isResetting: Bool = false
    @Published var rightAlbumVisible = false
    
    override init() {
        self.showDB = uiRepo.getShowDB()
        super.init()
    }

    func showDBView() {
        withAnimation {
            self.showDB = true
            self.uiRepo.setShowDB(true)
        }
    }

    func closeDBView() {
        withAnimation {
            self.showDB = false
            self.uiRepo.setShowDB(false)
        }
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
