import CisumUI
import AVKit
import Combine
import Foundation
import LocalAuthentication
import MagicKit
import MediaPlayer
import OSLog
import SwiftData
import SwiftUI
#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

@MainActor
enum Config: SuperLog {
    nonisolated static let emoji = "🧲"
    nonisolated static let verbose = false

    static let id = "com.yueyi.cisum"
    static let logger = Logger.self
    static let appSupportDir: URL? = MagicApp.getAppSpecificSupportDirectory()
    static let localContainer: URL? = MagicApp.getContainerDirectory()
    static let localDocumentsDir: URL? = MagicApp.getDocumentsDirectory()
    static let cloudDocumentsDir: URL? = MagicApp.getCloudDocumentsDirectory()
    static let databaseDir: URL = MagicApp.getDatabaseDirectory()
    static let containerIdentifier = "iCloud.yueyi.cisum"
    static let dbDirName = isDebug ? "db_debug" : "db_production"

    static var isDebug: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }

    @MainActor
    @ViewBuilder
    static var rootBackground: some View {
        CisumMagicBackground.sunset.opacity(1)
    }

    static func getDBRootDir() throws -> URL {
        let url = Config.databaseDir
            .appendingPathComponent(dbDirName, isDirectory: true)

        try ensureDirectory(at: url)

        return url
    }

    static let isDesktop = MagicApp.isDesktop
    static let isNotDesktop = MagicApp.isNotDesktop
    static let isiOS = MagicApp.isiOS

    // MARK: - Storage Configuration

    static let keyOfStorageLocation = "StorageLocation"

    /// 获取当前存储位置设置
    static func getStorageLocation() -> StorageLocation? {
        guard let savedLocation = UserDefaults.standard.string(forKey: keyOfStorageLocation),
              let location = StorageLocation(rawValue: savedLocation) else {
            return nil
        }

        guard getStorageRoot(for: location) != nil else {
            return nil
        }

        return location
    }

    /// 当前配置是否能解析到一个真实可用的媒体仓库根目录。
    static func hasUsableStorageLocation() -> Bool {
        getStorageLocation() != nil
    }

    /// iCloud 只有在容器 Documents 目录可解析时才可作为媒体仓库。
    static func isICloudStorageAvailable() -> Bool {
        getStorageRoot(for: .icloud) != nil
    }

    /// 更新存储位置设置
    static func updateStorageLocation(_ location: StorageLocation?) {
        if Self.verbose {
            os_log("\(Self.t)💾 更新存储位置设置: \(location?.rawValue ?? "nil")")
        }
        UserDefaults.standard.set(location?.rawValue, forKey: keyOfStorageLocation)

        // 发送存储位置更新通知
        NotificationCenter.postStorageLocationUpdated()
    }

    /// 获取存储根目录
    static func getStorageRoot() -> URL? {
        guard let location = getStorageLocation() else { return nil }
        return getStorageRoot(for: location)
    }

    /// 根据指定位置获取存储根目录
    static func getStorageRoot(for location: StorageLocation) -> URL? {
        switch location {
        case .icloud:
            return cloudDocumentsDir
        case .local:
            return localDocumentsDir
        case .custom:
            return nil
        }
    }

    /// 重置存储位置设置
    static func resetStorageLocation() {
        UserDefaults.standard.removeObject(forKey: keyOfStorageLocation)
        NotificationCenter.postStorageLocationDidReset()
    }

    /// 上半部分播放控制的最小高度
    static let controlViewMinHeight: CGFloat = Self.minHeight
    static let databaseViewHeightMin: CGFloat = 200
    static let minWidth: CGFloat = 350
    static let minHeight: CGFloat = 250
    static let defaultHeight: CGFloat = 360
    static let idealHeight: CGFloat = 650

    /// 大于此高度，可展示封面图
    static let minHeightToShowAlbum: CGFloat = 450

    #if os(macOS)
        static let canResize = true
    #else
        static let canResize = false
    #endif
}

extension Config {
    #if os(macOS)
        private static var appWindow: NSWindow? {
            NSApplication.shared.keyWindow
                ?? NSApplication.shared.mainWindow
                ?? NSApplication.shared.windows.first(where: { $0.isVisible })
                ?? NSApplication.shared.windows.first
        }
    #endif

    static func getWindowHeight() -> CGFloat {
        #if os(macOS)
            guard let window = appWindow else {
                os_log(.error, "\(t)无法获取窗口高度：当前没有可用窗口")
                return defaultHeight
            }

            let frame = window.frame
            let height = frame.size.height

            return sanitizedWindowHeight(height)
        #else
            return 0
        #endif
    }

    static func increseHeight(_ h: CGFloat, verbose: Bool = false) {
        #if os(macOS)
            guard h.isFinite, h > 0 else {
                os_log(.error, "\(t)无法增加窗口高度：无效增量 \(String(describing: h))")
                return
            }

            if verbose {
                os_log("\(t)增加 Height=\(h)")
            }

            guard let window = appWindow else {
                os_log(.error, "\(t)无法增加窗口高度：当前没有可用窗口")
                return
            }

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
            guard h.isFinite else {
                os_log(.error, "\(t)无法设置窗口高度：无效高度 \(String(describing: h))")
                return
            }

            let targetHeight = sanitizedWindowHeight(h)

            if verbose {
                os_log("\(t)设置Height=\(targetHeight)")
            }

            guard let window = appWindow else {
                os_log(.error, "\(t)无法设置窗口高度：当前没有可用窗口")
                return
            }

            var frame = window.frame
            let oldY = frame.origin.y
            let height = frame.size.height

            if verbose {
                os_log("\(t)设置前 Y=\(oldY) height=\(height)")
            }

            frame.origin.y = oldY + height - targetHeight
            frame.size.height = targetHeight

            if verbose {
                os_log("\(t)设置后 Y=\(frame.origin.y) height=\(frame.size.height)")
            }

            window.setFrame(frame, display: true)
        #endif
    }

    private static func sanitizedWindowHeight(_ h: CGFloat) -> CGFloat {
        guard h.isFinite else { return defaultHeight }
        return max(h, minHeight)
    }
}

// MARK: Database

extension Config {
    static func createDatabaseFile(name: String) throws -> URL {
        let directory = try Config.getDBRootDir()
            .appendingPathComponent(name, isDirectory: true)

        try ensureDirectory(at: directory)

        return directory.appendingPathComponent("\(name).db")
    }

    private static func ensureDirectory(at url: URL) throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue {
            try FileManager.default.removeItem(at: url)
        }

        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true,
            attributes: nil
        )
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
            _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

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

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
