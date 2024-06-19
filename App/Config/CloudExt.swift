import Foundation
import SwiftUI

extension Config {
    @AppStorage("App.iCloudEnabled")
    static var iCloudEnabled: Bool = true
    
    static func enableiCloud() {
        Config.iCloudEnabled = true
    }
    
    static func disableiCloud() {
        Config.iCloudEnabled = false
    }
    
    static var isStoreIniCloud: Bool {
        iCloudHelper.isCloudPath(url: Config.disk.audiosDir)
    }
}
