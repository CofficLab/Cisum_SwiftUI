import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

enum Config: SuperLog {
    static var emoji = "🧲"
    static let id = "com.yueyi.cisum"
    static let fm = FileManager.default
    static let logger = Logger.self
    static var maxAudioCount = 5
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

    static let appSupportDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    static let localContainer: URL? = localDocumentsDir?.deletingLastPathComponent()
    static let localDocumentsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first

    // MARK: iCloud 容器里的 Documents

    static var cloudDocumentsDir: URL? = fm.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent("Documents")

    static var coverDir: URL {
        if let localDocumentsDir = Config.localDocumentsDir {
            return localDocumentsDir.appendingPathComponent(coversDirName)
        }

        fatalError()
    }

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
        guard let url = Config.appSupportDir?
            .appendingPathComponent("Cisum_Database")
            .appendingPathComponent(dbDirName) else { return nil }

        // 如果目录不存在则创建
        if !fm.fileExists(atPath: url.path) {
            os_log("\(self.t) Creating database directory: \(url.path)")

            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }

        return url
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
