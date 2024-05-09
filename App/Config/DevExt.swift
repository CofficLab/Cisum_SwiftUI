import Foundation
import SwiftUI

// MARK: 开发调试

extension AppConfig {
    static var debug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}
