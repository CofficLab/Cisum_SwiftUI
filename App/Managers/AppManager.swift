import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

enum PrepareCloudDocumentsResult {
  case success(URL)
  case failure(Error)
}

enum PrepareResult {
    case success(iCloudDocumentsUrl: URL)
  case failure(Error)
}

enum AppMode {
    case Normal
    case Static
}

class AppManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static var iCloudDocumentsUrl: URL? = nil
    
    @Published var appMode: AppMode = .Normal
    @Published var showAlert: Bool = false
    @Published var showDB: Bool = false
    @Published var alertMessage: String = ""
    @Published var flashMessage: String = ""
    @Published var stateMessage: String = ""
    @Published var fixedMessage: String = ""
    @Published var isImporting: Bool = false
    
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
    
    static func getCloudDocumentsUrl() -> URL {
        if let url = FileManager.default.url(forUbiquityContainerIdentifier: AppConfig.containerIdentifier) {
            return url
        } else {
            return AppConfig.cloudDocumentsDir
        }
    }
}
