import Foundation
import SwiftUI

extension AppConfig {
    @AppStorage("App.iCloudEnabled")
    static var iCloudEnabled: Bool = true
    
    static func enableiCloud() {
        AppConfig.iCloudEnabled = true
    }
    
    static func disableiCloud() {
        AppConfig.iCloudEnabled = false
    }
    
    static var isStoreIniCloud: Bool {
        iCloudHelper.isCloudPath(url: AppConfig.disk.audiosDir)
    }
}
