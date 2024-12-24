import Foundation
import SwiftUI
import SwiftData
import OSLog

enum Config {
    static var label = "🧲 Config::"
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
    
    static func getDeviceId() -> String {
        if uuid.count > 0 {
            return uuid
        }
        
        uuid = UUID().uuidString
        
        return uuid
    }
    
    /// 封面图文件夹
    static let coversDirName = "covers"
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
