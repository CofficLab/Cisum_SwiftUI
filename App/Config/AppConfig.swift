import Foundation
import SwiftUI
import SwiftData
import OSLog

enum AppConfig {
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let coversDirName = "covers"
    static let audiosDirName = "audios"
    static let trashDirName = "trash"
    static let cacheDirName = "audios_cache"
    /// iCloud容器的ID
    static let containerIdentifier = "iCloud.yueyi.cisum"
    static let logger = Logger.self
    static let supportedExtensions = [
        "mp3",
        "m4a",
    ]
}

// MARK: APP状态

extension AppConfig {
    @AppStorage("App.CurrentAudio")
    static var currentAudio: URL?
    
    @AppStorage("App.CurrentMode")
    static var currentMode: String = PlayMode.Order.rawValue
    
    static func setCurrentAudio(_ audio: Audio) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        AppConfig.currentAudio = audio.url
    }
    
    static func setCurrentMode(_ mode: PlayMode) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        AppConfig.currentMode = mode.rawValue
    }
}

// MARK: 视图配置

extension AppConfig {
    /// 上半部分播放控制的高度
    static var controlViewHeight: CGFloat = 180
    static var databaseViewHeightMin: CGFloat = 200
    #if os(macOS)
    static var canResize = true
    #else
    static var canResize = false
    #endif
    static var getBackground: Color {
        #if os(macOS)
        Color(.controlBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
}

// MARK: 数据库配置

extension AppConfig {
    static func getContainer() -> ModelContainer {
        guard let url = AppConfig.localDocumentsDir?.appendingPathComponent("database.db") else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
            Audio.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            allowsSave: true,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: 队列配置

extension AppConfig {
    static let mainQueue = DispatchQueue.main
    static let bgQueue = DispatchQueue(label: "com.yueyi.bgqueue")
}

// MARK: 路径配置

extension AppConfig {
    static let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    static let localContainer = localDocumentsDir?.deletingLastPathComponent()
    static let localDocumentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    static let containerDir = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)
    static var cloudDocumentsDir: URL {
        if let c = containerDir {
            return c.appending(component: "Documents")
        }

        if let documentsDirectory = localDocumentsDir {
            return documentsDirectory
        }

        fatalError()
    }

    static var coverDir: URL {
        if let localDocumentsDir = AppConfig.localDocumentsDir {
            return localDocumentsDir.appendingPathComponent(coversDirName)
        }

        fatalError()
    }

    static var audiosDir: URL {
        let url = AppConfig.cloudDocumentsDir.appendingPathComponent(AppConfig.audiosDirName)

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("\(Logger.isMain)🍋 DB::创建 Audios 目录成功")
            } catch {
                os_log("\(Logger.isMain)创建 Audios 目录失败\n\(error.localizedDescription)")
            }
        }

        return url
    }

    static var trashDir: URL {
        let url = AppConfig.cloudDocumentsDir.appendingPathComponent(AppConfig.trashDirName)

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("\(Logger.isMain)🍋 DB::创建回收站目录成功")
            } catch {
                os_log("\(Logger.isMain)创建回收站目录失败\n\(error.localizedDescription)")
            }
        }

        return url
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
