import Foundation
import MagicKit

import OSLog
import SwiftData
import SwiftUI

@MainActor
enum Config: SuperLog {
    nonisolated static let emoji = "🧲"
    static let id = "com.yueyi.cisum"
    static let logger = Logger.self
    static let maxAudioCount = 5
    static let fm = FileManager.default
    static let appSupportDir: URL? = MagicApp.getAppSpecificSupportDirectory()
    static let localContainer: URL? = MagicApp.getContainerDirectory()
    static let localDocumentsDir: URL? = MagicApp.getDocumentsDirectory()
    static let cloudDocumentsDir: URL? = MagicApp.getCloudDocumentsDirectory()
    static let databaseDir: URL = MagicApp.getDatabaseDirectory()
    static let containerIdentifier = "iCloud.yueyi.cisum"
    static let dbDirName = debug ? "db_debug" : "db_production"
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

    static var isDebug: Bool { debug }
    
    static var rootBackground: some View {
        MagicBackground.mint
    }
    
    @AppStorage("App.UUID")
    static var uuid: String = ""

    static func getDeviceId() -> String {
        if uuid.count > 0 {
            return uuid
        }

        uuid = UUID().uuidString
        return uuid
    }

    static func getDBRootDir() throws -> URL {
        try Config.databaseDir
            .appendingPathComponent(dbDirName, isDirectory: true)
            .createIfNotExist()
    }
    
    static func getPlugins() -> [SuperPlugin] {
        return [
            WelcomePlugin(),
            SettingPlugin(),
            AudioPlugin(),
            CopyPlugin(),
//            BookPlugin()
            ResetPlugin()
        ]
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
