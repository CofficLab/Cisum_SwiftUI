import Foundation
import SwiftUI

extension Config {
    static var disk: any DiskContact {
        if Config.iCloudEnabled {
            DiskiCloud()
        } else {
            DiskLocal()
        }
    }
}
