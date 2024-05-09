import Foundation
import SwiftUI
import SwiftData
import OSLog

enum AppConfig {
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let logger = Logger.self
    static let supportedExtensions = [
        "mp3",
        "m4a",
        "flac",
        "wav"
    ]
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
