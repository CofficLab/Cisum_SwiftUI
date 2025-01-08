import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

@MainActor
enum Config: @preconcurrency SuperLog {
    static let emoji = "🧲"
    static let id = "com.yueyi.cisum"
    static let logger = Logger.self
    static let maxAudioCount = 5
    static let fm = FileManager.default
    static let supportedExtensions = [
        "mp3",
        "m4a",
        "flac",
        "wav",
    ]

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
    
    static var rootBackground: some View {
        MagicBackground.mint
    }

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
    static let appSupportDir: URL? = MagicApp.getAppSpecificSupportDirectory()
    static let localContainer: URL? = MagicApp.getContainerDirectory()
    static let localDocumentsDir: URL? = MagicApp.getDocumentsDirectory()
    static let cloudDocumentsDir: URL? = MagicApp.getCloudDocumentsDirectory()
    static let databaseDir: URL? = MagicApp.getDatabaseDirectory()

    static func getPlugins() -> [SuperPlugin] {
        return [
            WelcomePlugin(),
            SettingPlugin(),
            DebugPlugin(),
            AudioPlugin(),
            CopyPlugin(),
//            BookPlugin()
//            ResetPlugin()
        ]
    }

    static let containerIdentifier = "iCloud.yueyi.cisum"

    static let dbDirName = debug ? "db_debug" : "db_production"

    static func getDBRootDir() -> URL? {
        guard let url = Config.databaseDir?
            .appendingPathComponent(dbDirName) else { return nil }

        return try? url.createIfNotExist()
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
