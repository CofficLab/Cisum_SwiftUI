import Foundation
import SwiftUI

extension AppConfig {
    static var disk: DiskContact {
        if AppConfig.iCloudEnabled {
            DiskiCloud()
        } else {
            DiskLocal()
        }
    }
}
