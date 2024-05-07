import Foundation
import SwiftUI
import SwiftData
import OSLog

enum AppConfig {
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let coversDirName = "covers"
    static let audiosDirName = debug ? "audios_debug" : "audios"
    static let trashDirName = "trash"
    static let cacheDirName = "audios_cache"
    /// iCloud容器的ID
    static let containerIdentifier = "iCloud.yueyi.cisum"
    static let logger = Logger.self
    static let supportedExtensions = [
        "mp3",
        "m4a",
        "flac",
        "wav"
    ]
}

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
    static var rootBackground: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            BackgroundView.type2A
        }
    }
    /// 上半部分播放控制的最小高度
    static var controlViewMinHeight: CGFloat = Self.minHeight
    static var databaseViewHeightMin: CGFloat = 200
    static var minWidth: CGFloat = 350
    static var minHeight: CGFloat = 320
    static var defaultHeight: CGFloat = 360
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
    static var dbFileName = debug ? "database_debug.db" : "database.db"
    static func getContainer() -> ModelContainer {
        guard let url = AppConfig.localDocumentsDir?.appendingPathComponent(dbFileName) else {
            fatalError("Could not create ModelContainer")
        }

        let schema = Schema([
            Audio.self,
            CopyTask.self
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

#Preview {
    LayoutView()
}

#Preview("500") {
    LayoutView(width: 500)
}

#Preview("1000") {
    LayoutView(width: 1000)
}
