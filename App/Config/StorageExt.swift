import Foundation
import SwiftUI

extension Config {
    static var disk: DiskContact {
        if Config.iCloudEnabled {
            DiskiCloud()
        } else {
            DiskLocal()
        }
    }
}
