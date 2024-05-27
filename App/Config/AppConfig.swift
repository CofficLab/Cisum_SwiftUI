import Foundation
import SwiftUI
import SwiftData
import OSLog

enum AppConfig {
    static var label = "🧲 AppConfig::"
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let logger = Logger.self
    static let supportedExtensions = [
        "mp3",
        "m4a",
        "flac",
        "wav"
    ]
    
    // MARK: UUID
    
    @AppStorage("App.UUID")
    static var uuid: String = ""
    
    static func setUUID() {
        if uuid.count > 0 {
            return
        }
        
        uuid = UUID().uuidString
    }
}

#Preview {
    LayoutView()
}

#Preview("500") {
    LayoutView(width: 500)
}

#Preview("1000") {
    LayoutView(width: 1000)
}
