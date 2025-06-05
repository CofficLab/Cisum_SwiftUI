import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI
import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

import LocalAuthentication
import Foundation
import OSLog

@MainActor
enum Config: SuperLog {
    nonisolated static let emoji = "🧲"
    static let id = "com.yueyi.cisum"
    static let logger = Logger.self
    static let maxAudioCount = 5
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

    @MainActor
    @ViewBuilder
    static var rootBackground: some View {
        MagicBackground.mint
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
            ResetPlugin(),
            DebugPlugin()
        ]
    }

    static var getBackground: Color {
        #if os(macOS)
            Color(.controlBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }

    static let isDesktop = MagicApp.isDesktop
    static let isNotDesktop = MagicApp.isNotDesktop
    static let isiOS = MagicApp.isiOS

    /// 开发时如果不想显示背景，改成true
    static let noBackground = true

    /// 生产环境一定不会显示背景
    static func background(_ color: Color = .red) -> Color {
        Config.debug && !noBackground ? color.opacity(0.3) : Color.clear
    }

    /// 上半部分播放控制的最小高度
    static let controlViewMinHeight: CGFloat = Self.minHeight
    static let databaseViewHeightMin: CGFloat = 200
    static let minWidth: CGFloat = 350
    static let minHeight: CGFloat = 250
    static let defaultHeight: CGFloat = 360

    /// 大于此高度，可展示封面图
    static let minHeightToShowAlbum: CGFloat = 450

    #if os(macOS)
        static let canResize = true
    #else
        static let canResize = false
    #endif
}


extension Config {
    static func getWindowHeight() -> CGFloat {
        #if os(macOS)
        let window = NSApplication.shared.windows.first!
        let frame = window.frame
        let height = frame.size.height

        return height
        #else
        return 0
        #endif
    }

    static func increseHeight(_ h: CGFloat, verbose: Bool = false) {
        #if os(macOS)
        if verbose {
            os_log("\(t)增加 Height=\(h)")
        }
        
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        if verbose {
            os_log("\(t) 增加前 Y=\(oldY) height=\(height)")
        }

        frame.origin.y = oldY - h
        frame.size.height = height + h

        if verbose {
            os_log("\(t) 增加后 Y=\(frame.origin.y) height=\(frame.size.height)")
        }

        window.setFrame(frame, display: true)
        #endif
    }

    static func setHeight(_ h: CGFloat, verbose: Bool = false) {
        #if os(macOS)
        if verbose {
            os_log("\(t)设置Height=\(h)")
        }
        
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        if verbose {
            os_log("\(t)设置前 Y=\(oldY) height=\(height)")
        }

        frame.origin.y = oldY + height - h
        frame.size.height = h

        if verbose {
            os_log("\(t)设置后 Y=\(frame.origin.y) height=\(frame.size.height)")
        }

        window.setFrame(frame, display: true)
        #endif
    }
}

// MARK: FACEID

extension Config {
    static func isFaceIDAvailable() -> Bool {
        biometricType() == .faceID
    }
    
    static func biometricType() -> LABiometryType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            
            return authContext.biometryType
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}

// MARK: HomeIndicator

extension Config {
    static func hasHomeIndicator() -> Bool {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        }
        #endif
        
        return false
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
