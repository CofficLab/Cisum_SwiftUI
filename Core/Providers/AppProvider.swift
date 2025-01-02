import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI
import MagicKit
import MagicUI

class AppProvider: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog, SuperThread {
    static let emoji: String = "🐮"
    
    @Published var showDB: Bool = Config.showDB
    @Published var showSheet: Bool = true
    @Published var isImporting: Bool = false
    @Published var isDropping: Bool = false
    @Published var isResetting: Bool = false
    @Published var error: Error? = nil
    @Published var rightAlbumVisible = false
    @Published var dbViewType: DBViewType = .init(rawValue: Config.currentDBViewType)!
    
    func showDBView() {
        withAnimation {
            self.showDB = true
        }
        
        Task {
            Config.setShowDB(true)
        }
    }
    
    func closeDBView() {
        withAnimation {
            self.showDB = false
        }
        
        Task {
            Config.setShowDB(false)
        }
    }
    
    func toggleDBView() {
        showDB ? self.closeDBView() : self.showDBView()
    }
    
    func clearError() {
        self.main.async {
            self.error = nil
        }
    }

    func setError(_ error: Error) {
        self.main.async {
            self.error = error
        }
    }

    func setResetting(_ value: Bool) {
        self.main.async {
            self.isResetting = value
        }
    }
}
