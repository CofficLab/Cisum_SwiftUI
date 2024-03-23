import Foundation
import OSLog

extension DateComponentsFormatter {
    static let abbreviated: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        
        return formatter
    }()
    
    static let positional: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()
}

extension AppConfig.logger {
    static let loggingSubsystem: String = "com.yueyi.cisum"

    static let ui = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "UI")
    static let databaseManager = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "DatabaseManager")
    static let audioManager = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "AudioManger")
    static let app = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "App")
    static let audioListModel = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "AudioListModel")
    static let mediaPlayerManager = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "MediaPlayerManager")
    static let nodeEvents = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "NodeEvents")
    static let nodeDetail = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "NodeDetail")
    static let remoteNode = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "RemoteNode")
    static let remoteBody = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "RemoteBody")
    static let rootNode = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "RootNode")
    static let cloudKit = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "CloudKit")
    static let webView = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "WebView")
    static let persistence = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "Persistance")
    static let sideRow = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "SideRow")
    static let contentView = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "ContentView")
    static let main = AppConfig.logger(subsystem: Self.loggingSubsystem, category: "Main")

    func debugEvent(_ message: String) {
        self.debug("🐛🚀 \(message)")
    }
    
    func debugListen(_ message: String) {
        self.debug("🐛🐛🐛 👂👂👂 \(message)")
    }
    
    func debugDetect(_ message: String) {
        self.debug("🐛🐛🐛 🍋🍋🍋 \(message)")
    }
    
    func debugSomething(_ message: String) {
        self.debug("🐛✍️ \(message)")
    }
    
    func d(_ message: String) {
        self.debug("🐛🐛🐛 \(message)")
    }
    
    func i(_ message: String) {
        self.info("🐎🐎🐎 \(message)")
    }
    
    func e(_ message: String) {
        self.error("\n❌❌❌ \n\(message) \n❌❌❌ ")
    }
    
    func w(_ message: String) {
        self.warning("⚠️⚠️⚠️ \(message)")
    }
}

