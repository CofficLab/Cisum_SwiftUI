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
    static var controlViewHeight: CGFloat = 150
    
    @Published var appMode: AppMode = .Normal
    @Published var showAlert: Bool = false
    @Published var showDatabase: Bool = false
    @Published var alertMessage: String = ""
    @Published var flashMessage: String = ""
    @Published var stateMessage: String = ""
    @Published var fixedMessage: String = ""
    @Published var isImporting: Bool = false
    
    func setFlashMessage(_ message: String) {
        flashMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.flashMessage = ""
        }
    }
    
    // 负责所有的初始化操作
    static func prepare(_ callback: @escaping (_ result: PrepareResult) -> Void) {
        prepareCloudDocuments({ result in
            switch result {
            case .success(let url):
                callback(.success(iCloudDocumentsUrl: url))
            case .failure(let error):
                callback(.failure(error))
            }
        })
    }

    static func prepareCloudDocuments(_ callback: @escaping (_ result: PrepareCloudDocumentsResult) -> Void) {
        AppConfig.logger.cloudKit.info("初始化 iCloud Documents")
        
        if !iCloudHelper.iCloudEnabled() {
            AppConfig.logger.wild.warning("iCloud 未启用，使用本地目录")
            
            callback(.success(AppConfig.documentsDir))
            return
        }

        // Dispatch to a global queue because url(forUbiquityContainerIdentifier:) might take a nontrivial
        // amount of time to set up iCloud and return the requested URL
        DispatchQueue.global().async {
            if let url = FileManager.default.url(forUbiquityContainerIdentifier: AppConfig.container) {
                DispatchQueue.main.async {
                    AppConfig.logger.cloudKit.info("初始化 iCloud Documents 成功")

                    iCloudDocumentsUrl = url.appendingPathComponent("Documents")
                    callback(.success(iCloudDocumentsUrl!))
                }
            } else {
                DispatchQueue.main.async {
                    AppConfig.logger.cloudKit.fault("⛔️ 初始化 iCloud Documents 失败\n因为: url==nil")

                    callback(.failure(CloudDocsError.failedToInitialize))
                }
            }
        }
    }
    
    static func getCloudDocumentsUrl() -> URL {
        if let url = FileManager.default.url(forUbiquityContainerIdentifier: AppConfig.container) {
            return url
        } else {
            return AppConfig.documentsDir
        }
    }
}
