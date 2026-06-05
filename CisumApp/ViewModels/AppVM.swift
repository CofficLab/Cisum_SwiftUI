import AVKit
import Combine
import Foundation
import PluginRegistry

import MediaPlayer
import OSLog
import SwiftUI

@MainActor
class AppVM: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog, SuperThread {
    nonisolated static let emoji = "🐮"

    // 使用 UIRepo 来管理 UI 相关的数据
    private let uiRepo: UIRepo

    @Published private(set) var showDB: Bool
    @Published var isImporting: Bool = false
    @Published var isDropping: Bool = false
    @Published var rightAlbumVisible = false

    /// 是否为演示模式
    /// 用于 App Store 展示等场景，显示固定的示例数据而非真实数据库
    @Published var isDemoMode: Bool = false

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

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
