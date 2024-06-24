import Foundation
import SwiftUI

extension Config {
    static var disk: any Disk {
        if Config.iCloudEnabled {
            DiskiCloud()
        } else {
            DiskLocal()
        }
    }
}
