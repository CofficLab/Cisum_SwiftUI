import Foundation
import SwiftUI

// MARK: 开发调试

extension Config {
    static var debug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    
    static var isDebug: Bool {
        debug
    }
}
