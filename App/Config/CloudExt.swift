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
    
    static func setiCloud(_ v: Bool) {
        v ? enableiCloud() : disableiCloud()
    }
}
