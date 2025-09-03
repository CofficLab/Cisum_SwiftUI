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
    private let uiRepo: UIRepo
    
    @Published private(set) var showDB: Bool
    @Published var showSheet: Bool = true
    @Published var isImporting: Bool = false
    @Published var isDropping: Bool = false
    @Published var rightAlbumVisible = false
    
    init(uiRepo: UIRepo) {
        self.uiRepo = uiRepo
        self.showDB = uiRepo.getShowDB()
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
