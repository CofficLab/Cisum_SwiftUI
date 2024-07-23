import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class AppManager: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog {
    @Published var showAlert: Bool = false
    @Published var showDB: Bool = Config.showDB
    @Published var showCopying: Bool = false
    @Published var alertMessage: String = ""
    @Published var flashMessage: String = ""
    @Published var stateMessage: String = ""
    @Published var fixedMessage: String = ""
    @Published var isImporting: Bool = false
    @Published var isDropping: Bool = false
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
    
    func cleanStateMessage() {
        stateMessage = ""
    }
    
    func cleanFlashMessage() {
        flashMessage = ""
    }
    
    func setFlashMessage(_ message: String) {
        flashMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.flashMessage = ""
        }
    }
}
