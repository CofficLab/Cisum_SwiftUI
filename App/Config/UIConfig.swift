import Foundation
import SwiftUI
import SwiftData
import OSLog

enum UIConfig {
    static var isDesktop: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
    
    static var isNotDesktop: Bool { !isDesktop }
}

#Preview {
    RootView {
        ContentView()
    }
}
